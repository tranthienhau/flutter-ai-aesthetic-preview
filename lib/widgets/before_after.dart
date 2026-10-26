import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../state/providers.dart';
import '../theme.dart';
import 'common.dart';

/// Drag-to-compare slider. The "after" layer is clipped to the handle position
/// and always carries the AI simulation badge.
class BeforeAfterSlider extends ConsumerStatefulWidget {
  const BeforeAfterSlider({super.key, required this.preview, this.initial = 0.5});
  final Preview preview;
  final double initial;

  @override
  ConsumerState<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends ConsumerState<BeforeAfterSlider> {
  late double _pos = widget.initial;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return ClipRRect(
      borderRadius: BorderRadius.circular(R.card),
      child: LayoutBuilder(builder: (context, c) {
        final w = c.maxWidth;
        return GestureDetector(
          key: const Key('compare-slider'),
          onHorizontalDragUpdate: (d) => setState(() => _pos = (d.localPosition.dx / w).clamp(0.02, 0.98)),
          onTapDown: (d) => setState(() => _pos = (d.localPosition.dx / w).clamp(0.02, 0.98)),
          child: Stack(fit: StackFit.expand, children: [
            Image.asset(widget.preview.beforeAsset, fit: BoxFit.cover, alignment: const Alignment(0, -0.3)),
            ClipRect(
              clipper: _RightClip(_pos),
              child: previewAfter(widget.preview),
            ),
            Positioned(
              left: w * _pos - 1.5,
              top: 0,
              bottom: 0,
              child: Container(width: 3, color: Colors.white),
            ),
            Positioned(
              left: w * _pos - 22,
              top: c.maxHeight / 2 - 22,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: cardShadow),
                child: const Icon(Icons.code, size: 20, color: C.text),
              ),
            ),
            Positioned(
              left: 14,
              top: 14,
              child: Tag(s.t('result.before'), fg: C.text, bg: Colors.white),
            ),
            Positioned(
              right: 14,
              top: 14,
              child: Tag(s.t('result.after'), fg: Colors.white, bg: C.accentFill),
            ),
            const Positioned(left: 14, bottom: 14, child: AiBadge()),
          ]),
        );
      }),
    );
  }
}

/// Shows the after image on the right of the handle (screen space, so the
/// before/after reads the same way in Hebrew).
class _RightClip extends CustomClipper<Rect> {
  _RightClip(this.pos);
  final double pos;
  @override
  Rect getClip(Size size) => Rect.fromLTRB(size.width * pos, 0, size.width, size.height);
  @override
  bool shouldReclip(_RightClip old) => old.pos != pos;
}
