import 'package:flutter/material.dart';
import 'package:posio/app/theme/app_radii.dart';
import 'package:posio/core/design_system/components/app_glass_surface.dart';
import 'package:posio/core/design_system/icons/app_icons.dart';
import 'package:posio/features/pose_library/domain/entities/pose.dart';
import 'package:posio/features/pose_library/domain/entities/pose_image_source.dart';

enum _PoseCatalogAction { favorite, delete }

class PoseCatalogActionRegion extends StatelessWidget {
  const PoseCatalogActionRegion({
    required this.pose,
    required this.onFavoritePressed,
    required this.onDeletePressed,
    required this.child,
    super.key,
  });

  final Pose pose;
  final VoidCallback onFavoritePressed;
  final VoidCallback onDeletePressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (details) async {
        final renderBox = context.findRenderObject() as RenderBox;
        final tileRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
        final action = await showGeneralDialog<_PoseCatalogAction>(
          context: context,
          barrierDismissible: true,
          barrierLabel: MaterialLocalizations.of(
            context,
          ).modalBarrierDismissLabel,
          barrierColor: Colors.black.withValues(alpha: 0.72),
          transitionDuration: const Duration(milliseconds: 140),
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curvedAnimation,
              child: child,
            );
          },
          pageBuilder: (context, animation, secondaryAnimation) {
            return _PoseCatalogActionOverlay(
              pose: pose,
              tileRect: tileRect,
              highlightedChild: child,
            );
          },
        );

        if (action == _PoseCatalogAction.favorite) {
          onFavoritePressed();
          return;
        }
        if (action == _PoseCatalogAction.delete && context.mounted) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Delete this pose?'),
              content: const Text(
                'This removes the pose from My Poses and deletes its saved file.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
          if (confirmed == true) onDeletePressed();
        }
      },
      child: child,
    );
  }
}

class _PoseCatalogActionOverlay extends StatefulWidget {
  const _PoseCatalogActionOverlay({
    required this.pose,
    required this.tileRect,
    required this.highlightedChild,
  });

  static const _buttonSize = 52.0;
  static const _buttonGap = 10.0;

  final Pose pose;
  final Rect tileRect;
  final Widget highlightedChild;

  @override
  State<_PoseCatalogActionOverlay> createState() =>
      _PoseCatalogActionOverlayState();
}

class _PoseCatalogActionOverlayState
    extends State<_PoseCatalogActionOverlay>
    with SingleTickerProviderStateMixin {
  _PoseCatalogAction? _activeAction;
  bool _isCompleting = false;
  late final AnimationController _revealController;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      reverseDuration: const Duration(milliseconds: 320),
    );
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _revealController.forward();
    });
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final canDelete = widget.pose.imageSource == PoseImageSource.localFile;
    final placeOnRight = widget.tileRect.right +
            _PoseCatalogActionOverlay._buttonSize +
            _PoseCatalogActionOverlay._buttonGap <=
        screenSize.width;
    final actionLeft = (placeOnRight
            ? widget.tileRect.right + _PoseCatalogActionOverlay._buttonGap
            : widget.tileRect.left -
                _PoseCatalogActionOverlay._buttonSize -
                _PoseCatalogActionOverlay._buttonGap)
        .clamp(
          12.0,
          screenSize.width - _PoseCatalogActionOverlay._buttonSize - 12,
        )
        .toDouble();
    final actionCount = canDelete ? 2 : 1;
    final actionsHeight = (actionCount * _PoseCatalogActionOverlay._buttonSize) +
        ((actionCount - 1) * _PoseCatalogActionOverlay._buttonGap);
    final actionTop = (widget.tileRect.center.dy - (actionsHeight / 2))
        .clamp(12.0, screenSize.height - actionsHeight - 12)
        .toDouble();
    final originLeft =
        widget.tileRect.center.dx -
        (_PoseCatalogActionOverlay._buttonSize / 2);
    final originTop =
        widget.tileRect.center.dy -
        (_PoseCatalogActionOverlay._buttonSize / 2);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _dismiss,
            ),
          ),
          Positioned.fromRect(
            rect: widget.tileRect,
            child: IgnorePointer(child: widget.highlightedChild),
          ),
          _PoseActionMotion(
            animation: _revealController,
            interval: const Interval(0, 0.78, curve: Curves.easeOutBack),
            originLeft: originLeft,
            originTop: originTop,
            destinationLeft: actionLeft,
            destinationTop: actionTop,
            child: IgnorePointer(
              ignoring: _isCompleting,
              child: _PoseActionButton(
                icon: _activeAction == _PoseCatalogAction.favorite
                    ? AppIcons.favoriteSelected
                    : widget.pose.isFavorite
                    ? AppIcons.favoriteSelected
                    : AppIcons.favorite,
                tooltip: widget.pose.isFavorite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                color: const Color(0xFFFF6B9E),
                isAnimating: _activeAction == _PoseCatalogAction.favorite,
                onPressed: () => _completeAction(
                  _PoseCatalogAction.favorite,
                  const Duration(milliseconds: 360),
                ),
              ),
            ),
          ),
          if (canDelete)
            _PoseActionMotion(
              animation: _revealController,
              interval: const Interval(0.2, 1, curve: Curves.easeOutBack),
              originLeft: originLeft,
              originTop: originTop,
              destinationLeft: actionLeft,
              destinationTop:
                  actionTop +
                  _PoseCatalogActionOverlay._buttonSize +
                  _PoseCatalogActionOverlay._buttonGap,
              child: IgnorePointer(
                ignoring: _isCompleting,
                child: _PoseActionButton(
                  icon: AppIcons.trash,
                  tooltip: 'Delete pose',
                  color: Theme.of(context).colorScheme.error,
                  isAnimating: _activeAction == _PoseCatalogAction.delete,
                  onPressed: () => _completeAction(
                    _PoseCatalogAction.delete,
                    const Duration(milliseconds: 220),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _dismiss() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);
    await _closeOverlay();
  }

  Future<void> _completeAction(
    _PoseCatalogAction action,
    Duration duration,
  ) async {
    if (_isCompleting) return;
    setState(() {
      _isCompleting = true;
      _activeAction = action;
    });
    await Future<void>.delayed(duration);
    if (!mounted) return;
    await _closeOverlay(action);
  }

  Future<void> _closeOverlay([_PoseCatalogAction? action]) async {
    await _revealController.reverse();
    if (!mounted) return;
    Navigator.of(context).pop(action);
  }
}

class _PoseActionMotion extends StatelessWidget {
  const _PoseActionMotion({
    required this.animation,
    required this.interval,
    required this.originLeft,
    required this.originTop,
    required this.destinationLeft,
    required this.destinationTop,
    required this.child,
  });

  final Animation<double> animation;
  final Interval interval;
  final double originLeft;
  final double originTop;
  final double destinationLeft;
  final double destinationTop;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final progress = interval.transform(animation.value);
        final left = originLeft + ((destinationLeft - originLeft) * progress);
        final top = originTop + ((destinationTop - originTop) * progress);

        return Positioned(
          left: left,
          top: top,
          child: Opacity(
            opacity: progress.clamp(0.0, 1.0).toDouble(),
            child: Transform.scale(
              scale: 0.28 + (0.72 * progress),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _PoseActionButton extends StatelessWidget {
  const _PoseActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.isAnimating,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isAnimating;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isAnimating ? 1.26 : 1,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: isAnimating
              ? [
                  BoxShadow(
                    color: (color ?? Colors.white).withValues(alpha: 0.5),
                    blurRadius: 22,
                    spreadRadius: 3,
                  ),
                ]
              : const [],
        ),
        child: AppGlassSurface(
          borderRadius: BorderRadius.circular(AppRadii.full),
          blur: 18,
          tintColor: Colors.black.withValues(alpha: 0.56),
          borderColor: Colors.white.withValues(alpha: 0.18),
          child: IconButton(
            onPressed: onPressed,
            tooltip: tooltip,
            constraints: const BoxConstraints.tightFor(
              width: _PoseCatalogActionOverlay._buttonSize,
              height: _PoseCatalogActionOverlay._buttonSize,
            ),
            color: color ?? Colors.white,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 120),
              child: Icon(icon, key: ValueKey(icon)),
            ),
          ),
        ),
      ),
    );
  }
}
