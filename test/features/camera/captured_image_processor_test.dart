import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:posio/features/camera/data/services/captured_image_processor.dart';

void main() {
  test('center-crops a captured image to the requested ratio', () async {
    final directory = await Directory.systemTemp.createTemp('pose_ratio_test');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/capture.jpg');
    final source = image.Image(width: 400, height: 300);
    await file.writeAsBytes(image.encodeJpg(source));

    const processor = ImageCapturedImageProcessor();
    await processor.cropToRatio(file.path, 1);

    final result = image.decodeJpg(await file.readAsBytes());
    expect(result, isNotNull);
    expect(result!.width, 300);
    expect(result.height, 300);
  });
}
