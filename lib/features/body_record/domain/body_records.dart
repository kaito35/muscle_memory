import 'dart:typed_data';
import '../../../core/domain/domain_error.dart';

/// 数値ではなく「有効な体重」を表すValue Object。
class Weight {
  Weight(this.kg) {
    require(kg.isFinite && kg > 0 && kg <= 500, '体重は0より大きく500kg以下で入力してください');
  }
  final double kg;
  @override
  bool operator ==(Object other) => other is Weight && kg == other.kg;
  @override
  int get hashCode => kg.hashCode;
}

class WeightEntry {
  WeightEntry(
      {required this.id,
      required this.weight,
      required this.recordedAt,
      this.bodyFat,
      this.memo = ''}) {
    require(
        bodyFat == null ||
            (bodyFat!.isFinite && bodyFat! > 0 && bodyFat! < 100),
        '体脂肪率は0より大きく100未満で入力してください');
    require(memo.length <= 500, 'メモは500文字以内で入力してください');
  }
  final String id;
  final Weight weight;
  final DateTime recordedAt;
  final double? bodyFat;
  final String memo;
}

enum PhotoAngle {
  front('正面'),
  side('側面'),
  back('背面');

  const PhotoAngle(this.label);
  final String label;
}

class BodyPhoto {
  BodyPhoto(
      {required this.id,
      required Uint8List bytes,
      required this.recordedAt,
      required this.angle,
      this.memo = ''})
      : bytes = Uint8List.fromList(bytes).asUnmodifiableView() {
    require(bytes.isNotEmpty && bytes.length <= 5 * 1024 * 1024,
        '写真は5MB以下の画像を選んでください');
    require(memo.length <= 500, 'メモは500文字以内で入力してください');
  }
  final String id;
  final Uint8List bytes;
  final DateTime recordedAt;
  final PhotoAngle angle;
  final String memo;
}

class BodyRecords {
  BodyRecords(
      {Iterable<WeightEntry> weights = const [],
      Iterable<BodyPhoto> photos = const []})
      : weights = List.unmodifiable(weights.toList()
          ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt))),
        photos = List.unmodifiable(photos.toList()
          ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt)));
  final List<WeightEntry> weights;
  final List<BodyPhoto> photos;
}
