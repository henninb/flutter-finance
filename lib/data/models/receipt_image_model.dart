import 'package:equatable/equatable.dart';

class ReceiptImage extends Equatable {
  final int receiptImageId;
  final String owner;
  final int transactionId;
  final bool activeStatus;
  final String imageFormatType;
  final String image; // base64-encoded PNG
  final String thumbnail; // base64-encoded PNG 150x150

  const ReceiptImage({
    required this.receiptImageId,
    required this.owner,
    required this.transactionId,
    this.activeStatus = true,
    this.imageFormatType = 'png',
    required this.image,
    required this.thumbnail,
  });

  factory ReceiptImage.fromJson(Map<String, dynamic> json) {
    return ReceiptImage(
      receiptImageId: (json['receiptImageId'] as num).toInt(),
      owner: json['owner'] as String? ?? '',
      transactionId: (json['transactionId'] as num).toInt(),
      activeStatus: json['activeStatus'] as bool? ?? true,
      imageFormatType: json['imageFormatType'] as String? ?? 'png',
      image: json['image'] as String,
      thumbnail: json['thumbnail'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (receiptImageId != 0) 'receiptImageId': receiptImageId,
      if (owner.isNotEmpty) 'owner': owner,
      'transactionId': transactionId,
      'activeStatus': activeStatus,
      'imageFormatType': imageFormatType,
      'image': image,
      'thumbnail': thumbnail,
    };
  }

  ReceiptImage copyWith({
    int? receiptImageId,
    String? owner,
    int? transactionId,
    bool? activeStatus,
    String? imageFormatType,
    String? image,
    String? thumbnail,
  }) {
    return ReceiptImage(
      receiptImageId: receiptImageId ?? this.receiptImageId,
      owner: owner ?? this.owner,
      transactionId: transactionId ?? this.transactionId,
      activeStatus: activeStatus ?? this.activeStatus,
      imageFormatType: imageFormatType ?? this.imageFormatType,
      image: image ?? this.image,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  @override
  List<Object?> get props => [
        receiptImageId,
        transactionId,
        activeStatus,
        imageFormatType,
      ];
}
