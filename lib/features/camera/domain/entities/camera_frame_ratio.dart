enum CameraFrameRatio {
  portrait('16:9', 9 / 16),
  classic('4:3', 3 / 4),
  square('1:1', 1),
  full('Full', null);

  const CameraFrameRatio(this.label, this.aspectRatio);

  final String label;
  final double? aspectRatio;

  CameraFrameRatio get next {
    final values = CameraFrameRatio.values;
    return values[(index + 1) % values.length];
  }
}
