import 'dart:typed_data';

enum SimulationType { hair, makeup, filler }

enum TreatmentArea { lips, cheeks, jawline, forehead, underEye }

extension TreatmentAreaX on TreatmentArea {
  /// Filler areas are measured in ml, Botox areas in units.
  bool get isBotox => this == TreatmentArea.forehead;
  String get unit => isBotox ? 'units' : 'ml';
  double get min => isBotox ? 10 : 0.5;
  double get max => isBotox ? 40 : 2.0;
  double get step => isBotox ? 5 : 0.1;
  double get defaultAmount => isBotox ? 20 : 1.0;
}

class SimulationRequest {
  const SimulationRequest({
    required this.type,
    required this.photoAsset,
    this.hairStyle,
    this.hairColor,
    this.makeupLook,
    this.area,
    this.amount,
    this.naturalLook = true,
  });

  final SimulationType type;
  final String photoAsset;
  final String? hairStyle;
  final String? hairColor;
  final String? makeupLook;
  final TreatmentArea? area;
  final double? amount;
  final bool naturalLook;

  /// Short label shown on chips and history cards.
  String get label {
    switch (type) {
      case SimulationType.hair:
        return '${hairStyle ?? 'Soft bob'} + ${(hairColor ?? 'chestnut').toLowerCase()}';
      case SimulationType.makeup:
        return makeupLook ?? 'Soft glam';
      case SimulationType.filler:
        final a = area ?? TreatmentArea.lips;
        final v = amount ?? a.defaultAmount;
        final amt = a.isBotox ? '${v.round()} units' : '${v.toStringAsFixed(1)} ml';
        return '${areaName(a)} ${a.isBotox ? 'Botox' : 'filler'} $amt';
    }
  }

  /// Prompt sent to the generative image API. Identity-preserving, edit-only.
  String get prompt {
    const keep =
        'Keep the same person, identity, face shape, skin texture, expression, pose, lighting and background. '
        'Photorealistic, no beautification beyond the requested change.';
    switch (type) {
      case SimulationType.hair:
        return 'Edit this photo: change only the hairstyle to "${hairStyle ?? 'soft bob'}" with '
            '${hairColor ?? 'chestnut'} hair color. $keep';
      case SimulationType.makeup:
        return 'Edit this photo: apply "${makeupLook ?? 'soft glam'}" makeup. $keep';
      case SimulationType.filler:
        final a = area ?? TreatmentArea.lips;
        final v = amount ?? a.defaultAmount;
        final dose = a.isBotox ? '${v.round()} units of Botox' : '${v.toStringAsFixed(1)} ml of hyaluronic filler';
        return 'Edit this photo to simulate a ${naturalLook ? 'natural, subtle' : 'visible'} result of $dose '
            'in the ${areaName(a).toLowerCase()} area. $keep';
    }
  }
}

String areaName(TreatmentArea a) => switch (a) {
      TreatmentArea.lips => 'Lip',
      TreatmentArea.cheeks => 'Cheek',
      TreatmentArea.jawline => 'Jawline',
      TreatmentArea.forehead => 'Forehead',
      TreatmentArea.underEye => 'Under-eye',
    };

class Preview {
  const Preview({
    required this.id,
    required this.request,
    required this.beforeAsset,
    required this.afterAsset,
    required this.createdAt,
    this.afterBytes,
    this.sharedWithClinic = false,
  });

  final String id;
  final SimulationRequest request;
  final String beforeAsset;
  final String afterAsset;
  final DateTime createdAt;

  /// Set when the image came back from the live generative API.
  final Uint8List? afterBytes;
  final bool sharedWithClinic;

  Preview copyWith({bool? sharedWithClinic}) => Preview(
        id: id,
        request: request,
        beforeAsset: beforeAsset,
        afterAsset: afterAsset,
        createdAt: createdAt,
        afterBytes: afterBytes,
        sharedWithClinic: sharedWithClinic ?? this.sharedWithClinic,
      );
}

class ClinicSession {
  const ClinicSession({
    required this.client,
    required this.avatar,
    required this.time,
    required this.treatment,
    required this.shared,
  });

  final String client;
  final String avatar;
  final String time;
  final String treatment;
  final bool shared;
}
