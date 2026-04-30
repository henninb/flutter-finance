import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../data_sources/remote/dio_provider.dart';
import '../models/receipt_image_model.dart';

final _logger = Logger();

class ReceiptImageRepository {
  final Dio _dio;

  ReceiptImageRepository(this._dio);

  Future<List<ReceiptImage>> getAllActive() async {
    _logger.i('🖼️ ReceiptImageRepository: Fetching all active receipt images');
    try {
      final response = await _dio.get('/receipt/image/active');
      _logger.d('📥 ReceiptImageRepository: Response: ${response.data}');

      if (response.data is! List) {
        _logger.e('❌ ReceiptImageRepository: Invalid response format');
        throw Exception('Invalid response format for receipt images');
      }

      final images = (response.data as List)
          .map((e) => ReceiptImage.fromJson(e as Map<String, dynamic>))
          .toList();
      _logger.i(
        '✅ ReceiptImageRepository: Fetched ${images.length} receipt images',
      );
      return images;
    } on DioException catch (e) {
      _logger.e('❌ ReceiptImageRepository: Failed to fetch receipt images');
      _logger.e('   Status code: ${e.response?.statusCode}');
      _logger.e('   Response data: ${e.response?.data}');
      throw Exception('Failed to fetch receipt images: ${e.message}');
    } catch (e) {
      _logger.e('❌ ReceiptImageRepository: Unexpected error: $e');
      rethrow;
    }
  }

  Future<ReceiptImage> uploadForTransaction(
    String guid,
    Uint8List imageBytes,
  ) async {
    if (guid.trim().isEmpty) throw ArgumentError('guid must not be empty');
    if (imageBytes.isEmpty) throw ArgumentError('imageBytes must not be empty');
    _logger.i(
      '📤 ReceiptImageRepository: Uploading receipt image for transaction $guid',
    );
    try {
      final response = await _dio.put(
        '/transaction/update/receipt/image/$guid',
        data: base64Encode(imageBytes),
        options: Options(contentType: 'text/plain'),
      );
      _logger.d('📥 ReceiptImageRepository: Response: ${response.data}');

      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid response format for uploaded receipt image');
      }

      final image = ReceiptImage.fromJson(
        response.data as Map<String, dynamic>,
      );
      _logger.i(
        '✅ ReceiptImageRepository: Uploaded receipt image id=${image.receiptImageId}',
      );
      return image;
    } on DioException catch (e) {
      _logger.e('❌ ReceiptImageRepository: Failed to upload receipt image');
      _logger.e('   Status code: ${e.response?.statusCode}');
      _logger.e('   Response data: ${e.response?.data}');
      throw Exception('Failed to upload receipt image: ${e.message}');
    } catch (e) {
      _logger.e('❌ ReceiptImageRepository: Unexpected error: $e');
      rethrow;
    }
  }

  Future<void> deleteForTransaction(String guid) async {
    if (guid.trim().isEmpty) throw ArgumentError('guid must not be empty');
    _logger.i(
      '🗑️ ReceiptImageRepository: Deleting receipt image for transaction $guid',
    );
    try {
      await _dio.delete('/transaction/receipt/image/$guid');
      _logger.i('✅ ReceiptImageRepository: Receipt image deleted successfully');
    } on DioException catch (e) {
      _logger.e('❌ ReceiptImageRepository: Failed to delete receipt image');
      _logger.e('   Status code: ${e.response?.statusCode}');
      _logger.e('   Response data: ${e.response?.data}');
      throw Exception('Failed to delete receipt image: ${e.message}');
    } catch (e) {
      _logger.e('❌ ReceiptImageRepository: Unexpected error: $e');
      rethrow;
    }
  }
}

final receiptImageRepositoryProvider = Provider<ReceiptImageRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReceiptImageRepository(dio);
});
