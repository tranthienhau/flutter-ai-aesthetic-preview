import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/models.dart';

class SimulationResult {
  const SimulationResult({required this.afterAsset, this.afterBytes});
  final String afterAsset;
  final Uint8List? afterBytes;
}

/// Generates the AI "after" image for a request.
abstract class SimulationService {
  Future<SimulationResult> generate(SimulationRequest req, {void Function(int step)? onStep});
}

/// Offline demo: returns pre-rendered results bundled in assets/sim/.
class MockSimulationService implements SimulationService {
  MockSimulationService({this.stepDelay = const Duration(milliseconds: 700)});
  final Duration stepDelay;

  @override
  Future<SimulationResult> generate(SimulationRequest req, {void Function(int step)? onStep}) async {
    for (var i = 1; i <= 4; i++) {
      await Future<void>.delayed(stepDelay);
      onStep?.call(i);
    }
    final asset = switch (req.type) {
      SimulationType.hair => 'assets/sim/after-hair-copper.jpg',
      SimulationType.makeup => 'assets/sim/after-makeup.jpg',
      SimulationType.filler => 'assets/sim/after-lips.jpg',
    };
    return SimulationResult(afterAsset: asset);
  }
}

/// Live path: Gemini 2.5 Flash Image ("Nano Banana") image edit.
/// In production this call runs on the backend (Cloud Function / Supabase
/// Edge Function) so the API key never ships in the app; the app uploads the
/// photo over TLS to a short-lived signed URL and the backend deletes it
/// after 30 days or on user request.
class GeminiSimulationService implements SimulationService {
  GeminiSimulationService(this.apiKey, {http.Client? client}) : _http = client ?? http.Client();
  final String apiKey;
  final http.Client _http;
  static const model = 'gemini-2.5-flash-image';

  @override
  Future<SimulationResult> generate(SimulationRequest req, {void Function(int step)? onStep}) async {
    final photo = await rootBundle.load(req.photoAsset);
    onStep?.call(1);
    onStep?.call(2);
    final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent');
    final res = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json', 'x-goog-api-key': apiKey},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': req.prompt},
              {
                'inline_data': {'mime_type': 'image/jpeg', 'data': base64Encode(photo.buffer.asUint8List())}
              },
            ]
          }
        ],
      }),
    );
    onStep?.call(3);
    if (res.statusCode != 200) {
      throw Exception('Image API ${res.statusCode}');
    }
    final parts = (jsonDecode(res.body)['candidates'][0]['content']['parts'] as List);
    final img = parts.firstWhere((p) => p['inlineData'] != null || p['inline_data'] != null);
    final data = (img['inlineData'] ?? img['inline_data'])['data'] as String;
    onStep?.call(4);
    return SimulationResult(afterAsset: req.photoAsset, afterBytes: base64Decode(data));
  }
}
