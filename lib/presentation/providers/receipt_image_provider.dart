import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';

import '../../data/models/receipt_image_model.dart';
import '../../data/repositories/receipt_image_repository.dart';

// Top-level function required for compute()
List<Uint8List> processReceiptImage(Uint8List rawBytes) {
  final decoded = img.decodeImage(rawBytes);
  if (decoded == null) throw Exception('Could not decode image');

  // Shrink until encoded PNG is under 500 KB
  const maxBytes = 500 * 1024;
  var current = decoded;
  var pngBytes = img.encodePng(current);

  while (pngBytes.length > maxBytes && current.width > 200) {
    final w = (current.width * 0.75).round();
    final h = (current.height * 0.75).round();
    current = img.copyResize(decoded, width: w, height: h);
    pngBytes = img.encodePng(current);
  }

  // Width guard stopped the loop before hitting the size target; the caller
  // receives the best effort result.
  if (pngBytes.length > maxBytes) {
    Logger().w(
      '⚠️ processReceiptImage: image still ${pngBytes.length} bytes after '
      'resize (min width reached). Uploading anyway.',
    );
  }

  // 150x150 square thumbnail
  final thumb = img.copyResizeCropSquare(decoded, size: 150);
  final thumbBytes = img.encodePng(thumb);

  return [Uint8List.fromList(pngBytes), Uint8List.fromList(thumbBytes)];
}

class ReceiptImagesState extends Equatable {
  final Map<int, ReceiptImage> byTransactionId;
  final bool isLoading;
  final String? error;

  const ReceiptImagesState({
    this.byTransactionId = const {},
    this.isLoading = false,
    this.error,
  });

  ReceiptImagesState copyWith({
    Map<int, ReceiptImage>? byTransactionId,
    bool? isLoading,
    String? error,
  }) {
    return ReceiptImagesState(
      byTransactionId: byTransactionId ?? this.byTransactionId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [byTransactionId, isLoading, error];
}

class ReceiptImagesNotifier extends Notifier<ReceiptImagesState> {
  late ReceiptImageRepository _repo;
  final _log = Logger();

  @override
  ReceiptImagesState build() {
    _repo = ref.watch(receiptImageRepositoryProvider);
    return const ReceiptImagesState();
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final images = await _repo.getAllActive();
      final map = {for (final i in images) i.transactionId: i};
      state = state.copyWith(isLoading: false, byTransactionId: map);
    } catch (e) {
      _log.e('❌ Failed to load receipt images', error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> uploadForTransaction(
    int transactionId,
    String guid,
    Uint8List imageBytes,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final created = await _repo.uploadForTransaction(guid, imageBytes);
      // Optimistically update local state so the thumbnail appears immediately.
      final updated = Map<int, ReceiptImage>.from(state.byTransactionId);
      updated[transactionId] = created;
      state = state.copyWith(isLoading: false, byTransactionId: updated);
      _log.i('✅ Receipt image uploaded for transaction $transactionId');
      await loadAll();
    } catch (e) {
      _log.e('❌ Failed to upload receipt image for transaction $transactionId',
          error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteForTransaction(int transactionId, String guid) async {
    if (state.byTransactionId[transactionId] == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.deleteForTransaction(guid);
      final updated = Map<int, ReceiptImage>.from(state.byTransactionId);
      updated.remove(transactionId);
      state = state.copyWith(isLoading: false, byTransactionId: updated);
      _log.i('🗑️ Receipt image deleted for transaction $transactionId');
    } catch (e) {
      _log.e(
          '❌ Failed to delete receipt image for transaction $transactionId',
          error: e);
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final receiptImagesProvider =
    NotifierProvider<ReceiptImagesNotifier, ReceiptImagesState>(
      ReceiptImagesNotifier.new,
    );
