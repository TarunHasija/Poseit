import 'package:flutter/material.dart';

class CameraCaptureButton extends StatelessWidget {
  const CameraCaptureButton({
    required this.onPressed,
    this.isCapturing = false,
    super.key,
  });

  final VoidCallback? onPressed;
  final bool isCapturing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isCapturing ? 'Capturing photo' : 'Take photo',
      enabled: onPressed != null && !isCapturing,
      child: SizedBox.square(
        dimension: 88,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: isCapturing ? null : onPressed,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: Colors.black.withValues(alpha: 0.14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x52000000),
                      blurRadius: 12,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.94),
                    ),
                    // Keep the shutter visually consistent while the photo
                    // is being finalized in the background.
                    child: null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
