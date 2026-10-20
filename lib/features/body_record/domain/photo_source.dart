import 'dart:typed_data';

abstract interface class PhotoSource {
  /// 選択キャンセル時はnull。プラットフォーム固有の型を外へ漏らさない。
  Future<Uint8List?> pick();
}
