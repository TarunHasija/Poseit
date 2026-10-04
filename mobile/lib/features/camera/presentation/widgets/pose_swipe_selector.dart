import 'package:flutter/material.dart';
import 'package:posio/features/pose_library/domain/entities/pose.dart';
import 'package:posio/features/pose_library/presentation/widgets/pose_image.dart';

class PoseSwipeSelector extends StatefulWidget {
  const PoseSwipeSelector({
    required this.poses,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<Pose> poses;
  final int? selectedIndex;
  final ValueChanged<int?> onSelected;

  @override
  State<PoseSwipeSelector> createState() => _PoseSwipeSelectorState();
}

class _PoseSwipeSelectorState extends State<PoseSwipeSelector> {
  late final PageController _pageController;
  late int _currentPage;
  bool _isProgrammaticScroll = false;

  int get _selectedPage => (widget.selectedIndex ?? -1) + 1;

  @override
  void initState() {
    super.initState();
    _currentPage = _selectedPage;
    _pageController = PageController(
      initialPage: _selectedPage,
      viewportFraction: 0.18,
    );
  }

  @override
  void didUpdateWidget(covariant PoseSwipeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedPage == _currentPage) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_pageController.hasClients) return;
      _isProgrammaticScroll = true;
      await _pageController.animateToPage(
        _selectedPage,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
      if (mounted) _isProgrammaticScroll = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.poses.length + 1,
            onPageChanged: (page) {
              _currentPage = page;
              if (_isProgrammaticScroll) return;
              widget.onSelected(page == 0 ? null : page - 1);
            },
            itemBuilder: (context, page) {
              final pose = page == 0 ? null : widget.poses[page - 1];

              return Center(
                child: AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    final currentPage = _pageController.hasClients
                        ? _pageController.page ?? _currentPage.toDouble()
                        : _currentPage.toDouble();
                    final distance = (currentPage - page)
                        .abs()
                        .clamp(0.0, 1.0)
                        .toDouble();
                    final dimension = 66.0 - (20.0 * distance);

                    return SizedBox.square(
                      key: ValueKey('pose_thumbnail_$page'),
                      dimension: dimension,
                      child: child,
                    );
                  },
                  child: Semantics(
                    button: true,
                    selected: page == _selectedPage,
                    label: pose?.title ?? 'No pose',
                    child: ClipOval(
                      child: pose == null
                          ? const SizedBox.shrink()
                          : PoseImage(pose: pose, fit: BoxFit.cover),
                    ),
                  ),
                ),
              );
            },
          ),
          IgnorePointer(
            child: Semantics(
              label: 'Selected pose frame',
              child: DecoratedBox(
                key: const ValueKey('pose_selection_ring'),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: const [
                    BoxShadow(color: Color(0x66000000), blurRadius: 8),
                  ],
                ),
                child: const SizedBox.square(dimension: 76),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
