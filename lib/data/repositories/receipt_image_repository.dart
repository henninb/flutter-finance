import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data_sources/remote/dio_provider.dart';
import '../models/receipt_image_model.dart';

class ReceiptImageRepository {
  final Dio _dio;

  ReceiptImageRepository(this._dio);

  Future<List<ReceiptImage>> getAllActive() async {
    final response = await _dio.get('/receipt/image/active');
    return (response.data as List)
        .map((e) => ReceiptImage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ReceiptImage> uploadForTransaction(
    String guid,
    Uint8List imageBytes,
  ) async {
    final response = await _dio.put(
      '/transaction/update/receipt/image/$guid',
      data: base64Encode(imageBytes),
      options: Options(contentType: 'text/plain'),
    );
    return ReceiptImage.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteForTransaction(String guid) async {
    await _dio.delete('/transaction/receipt/image/$guid');
  }
}

final receiptImageRepositoryProvider = Provider<ReceiptImageRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReceiptImageRepository(dio);
});
