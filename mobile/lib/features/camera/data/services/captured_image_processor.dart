import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as image;

abstract interface class CapturedImageProcessor {
  Future<void> cropToRatio(String path, double targetRatio);
}

final class ImageCapturedImageProcessor implements CapturedImageProcessor {
  const ImageCapturedImageProcessor();

  @override
  Future<void> cropToRatio(String path, double targetRatio) async {
    final sourceBytes = await File(path).readAsBytes();
    final result = await Isolate.run(
      () => _crop(sourceBytes: sourceBytes, targetRatio: targetRatio),
    );
    await File(path).writeAsBytes(result, flush: true);
  }

  Uint8List _crop({
    required Uint8List sourceBytes,
    required double targetRatio,
  }) {
    final decoded = image.decodeImage(sourceBytes);
    if (decoded == null) {
      throw const FormatException('The captured photo could not be decoded.');
    }

    final oriented = image.bakeOrientation(decoded);
    final sourceRatio = oriented.width / oriented.height;
    late final int cropWidth;
    late final int cropHeight;

    if (sourceRatio > targetRatio) {
      cropHeight = oriented.height;
      cropWidth = (cropHeight * targetRatio).round();
    } else {
      cropWidth = oriented.width;
      cropHeight = (cropWidth / targetRatio).round();
    }

    final cropped = image.copyCrop(
      oriented,
      x: (oriented.width - cropWidth) ~/ 2,
      y: (oriented.height - cropHeight) ~/ 2,
      width: cropWidth,
      height: cropHeight,
    );
    return image.encodeJpg(cropped, quality: 92);
  }
}
