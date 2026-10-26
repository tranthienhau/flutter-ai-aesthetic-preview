import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../state/providers.dart';
import '../theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label, {super.key, this.onPressed, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: C.accentFill,
          disabledBackgroundColor: C.disabled,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontFamily: 'PublicSans', fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton(this.label, {super.key, this.onPressed, this.icon, this.danger = false});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final c = danger ? C.danger : C.accentFill;
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: c,
          side: BorderSide(color: c, width: 1.5),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontFamily: 'PublicSans', fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color, this.border});
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? C.surface,
        borderRadius: BorderRadius.circular(R.card),
        border: border != null ? Border.all(color: border!, width: 2) : null,
        boxShadow: color == null ? cardShadow : null,
      ),
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}

class MirraChip extends StatelessWidget {
  const MirraChip(this.label, {super.key, this.selected = false, this.onTap, this.dot});
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color? dot;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? C.accentTint : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? C.accentFill : C.border, width: selected ? 1.5 : 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (dot != null) ...[
            Container(width: 12, height: 12, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
            const SizedBox(width: 6),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: selected ? C.accentFill : C.text2)),
        ]),
      ),
    );
  }
}

class Tag extends StatelessWidget {
  const Tag(this.label, {super.key, this.fg = C.accentFill, this.bg = C.accentTint, this.icon});
  final String label;
  final Color fg;
  final Color bg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg)),
      ]),
    );
  }
}

/// Permanent label on every AI-generated image.
class AiBadge extends ConsumerWidget {
  const AiBadge({super.key, this.small = false});
  final bool small;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 8 : 10, vertical: small ? 4 : 6),
      decoration: BoxDecoration(color: const Color(0xCC0C1F18), borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.auto_awesome_outlined, size: small ? 12 : 14, color: Colors.white),
        const SizedBox(width: 4),
        Text(s.t('ai.badge'),
            style: TextStyle(color: Colors.white, fontSize: small ? 12 : 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class Disclaimer extends ConsumerWidget {
  const Disclaimer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: C.surfaceAlt, borderRadius: BorderRadius.circular(R.control), border: Border.all(color: C.border)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline, size: 20, color: C.text2),
        const SizedBox(width: 10),
        Expanded(child: Text(s.t('ai.disclaimer'), style: const TextStyle(fontSize: 14, color: C.text2, height: 1.4))),
      ]),
    );
  }
}

class PhotoBox extends StatelessWidget {
  const PhotoBox(this.asset, {super.key, this.radius = R.card, this.height, this.width, this.alignment = Alignment.center});
  final String asset;
  final double radius;
  final double? height;
  final double? width;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(asset, height: height, width: width, fit: BoxFit.cover, alignment: alignment),
    );
  }
}

Widget previewAfter(Preview p, {BoxFit fit = BoxFit.cover}) => p.afterBytes != null
    ? Image.memory(p.afterBytes!, fit: fit)
    : Image.asset(p.afterAsset, fit: fit, alignment: const Alignment(0, -0.3));

class Avatar extends StatelessWidget {
  const Avatar(this.asset, {super.key, this.size = 36});
  final String asset;
  final double size;
  @override
  Widget build(BuildContext context) => ClipOval(
        child: Image.asset(asset, width: size, height: size, fit: BoxFit.cover, alignment: const Alignment(0, -0.4)),
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Row(children: [
          Expanded(child: Text(text, style: const TextStyle(fontFamily: 'Spectral', fontSize: 22, fontWeight: FontWeight.w600))),
          ?trailing,
        ]),
      );
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader(this.title, {super.key, this.caption, this.below});
  final String title;
  final String? caption;
  final Widget? below;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (caption != null) Text(caption!, style: T.caption),
            Text(title, style: T.display),
            if (below != null) ...[const SizedBox(height: 8), below!],
          ]),
        ),
        const Avatar('assets/images/avatar-noa.jpg', size: 40),
      ]),
    );
  }
}
