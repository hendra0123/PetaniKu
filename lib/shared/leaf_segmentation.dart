part of 'shared.dart';

class LeafSegmentation {
  static const platform = MethodChannel("com.example.leaf_segmentation");

  static Future<String> segment(String imgPath) async {
    try {
      if (!imgPath.endsWith("jpg") && !imgPath.endsWith("jpeg") && !imgPath.endsWith("png")) {
        throw "tipe gambar harus berupa jpg, jpeg, atau png";
      }
      final result = await platform.invokeMethod("segment", {"imgPath": imgPath});
      return result; // Return the processed image path or result.
    } on Exception catch (e) {
      throw "Segmentasi gagal: ${e.toString()}";
    }
  }
}
