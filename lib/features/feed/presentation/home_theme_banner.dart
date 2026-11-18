import 'package:material_ui/material_ui.dart';

final class HomeThemeBanner extends StatelessWidget {
  const HomeThemeBanner({super.key, required this.onRefresh});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final radius = BorderRadius.circular(24);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: colors.outlineVariant),
        gradient: LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [colors.primaryContainer, colors.secondaryContainer],
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final artWidth = constraints.maxWidth >= 244
                ? (constraints.maxWidth * 0.42).clamp(92.0, 150.0)
                : 0.0;
            return Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [
                if (artWidth > 0)
                  PositionedDirectional(
                    end: 8,
                    bottom: -26,
                    width: artWidth,
                    height: artWidth,
                    child: IgnorePointer(
                      child: Image.asset(
                        'assets/branding/home_mascot.webp',
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 128),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      18,
                      12,
                      artWidth + 12,
                      12,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'BiliSail',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: colors.onSurface,
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FilledButton.icon(
                          onPressed: onRefresh,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('换一批', maxLines: 1),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: const Size(0, 38),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
