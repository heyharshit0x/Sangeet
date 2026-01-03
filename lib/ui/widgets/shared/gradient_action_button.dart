import 'package:flutter/material.dart';

enum GradientButtonSize { small, medium, large }

class GradientActionButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final List<Color>? gradientColors;
  final GradientButtonSize size;
  final bool isLoading;
  final bool iconOnly;
  final double? width;

  const GradientActionButton({
    super.key,
    this.label,
    this.icon,
    this.onPressed,
    this.gradientColors,
    this.size = GradientButtonSize.medium,
    this.isLoading = false,
    this.iconOnly = false,
    this.width,
  }) : assert(icon != null || label != null,
            'Either icon or label must be provided');

  @override
  State<GradientActionButton> createState() => _GradientActionButtonState();
}

class _GradientActionButtonState extends State<GradientActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _height {
    switch (widget.size) {
      case GradientButtonSize.small:
        return 40;
      case GradientButtonSize.medium:
        return 50;
      case GradientButtonSize.large:
        return 60;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case GradientButtonSize.small:
        return 14;
      case GradientButtonSize.medium:
        return 16;
      case GradientButtonSize.large:
        return 18;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case GradientButtonSize.small:
        return 18;
      case GradientButtonSize.medium:
        return 22;
      case GradientButtonSize.large:
        return 26;
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultGradient = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
    ];
    final gradient = widget.gradientColors ?? defaultGradient;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: isDisabled
            ? null
            : (_) {
                _controller.forward();
              },
        onTapUp: isDisabled
            ? null
            : (_) {
                _controller.reverse();
                widget.onPressed?.call();
              },
        onTapCancel: isDisabled
            ? null
            : () {
                _controller.reverse();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _height,
          width: widget.iconOnly ? _height : widget.width,
          decoration: BoxDecoration(
            gradient: isDisabled
                ? LinearGradient(
                    colors: [
                      Colors.grey.withValues(alpha: 0.3),
                      Colors.grey.withValues(alpha: 0.2),
                    ],
                  )
                : LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius:
                BorderRadius.circular(widget.iconOnly ? _height / 2 : 16),
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: gradient[0].withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : widget.onPressed,
              borderRadius:
                  BorderRadius.circular(widget.iconOnly ? _height / 2 : 16),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.iconOnly ? 0 : 20,
                  vertical: 0,
                ),
                child: widget.isLoading
                    ? Center(
                        child: SizedBox(
                          width: _iconSize,
                          height: _iconSize,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null)
                            Icon(
                              widget.icon,
                              color: Colors.white,
                              size: _iconSize,
                            ),
                          if (widget.icon != null &&
                              widget.label != null &&
                              !widget.iconOnly)
                            const SizedBox(width: 8),
                          if (widget.label != null && !widget.iconOnly)
                            Text(
                              widget.label!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
