import 'dart:async';

import 'package:flutter/services.dart';

class YoutubeMp3ConversionResult {
  final bool success;
  final String message;
  final String? filePath;
  final String? rawOutput;

  const YoutubeMp3ConversionResult({
    required this.success,
    required this.message,
    this.filePath,
    this.rawOutput,
  });

  factory YoutubeMp3ConversionResult.fromMap(Map<Object?, Object?> map) {
    return YoutubeMp3ConversionResult(
      success: map['success'] == true,
      message: map['message'] as String? ?? 'Unknown conversion result.',
      filePath: map['filePath'] as String?,
      rawOutput: map['rawOutput'] as String?,
    );
  }

  factory YoutubeMp3ConversionResult.error(String message) {
    return YoutubeMp3ConversionResult(
      success: false,
      message: message,
    );
  }
}

class YoutubeMp3Service {
  static const MethodChannel _channel = MethodChannel('com.example.myapp/ytmp3');
  static const EventChannel _eventChannel =
      EventChannel('com.example.myapp/ytmp3/events');

  Stream<String> sharedYoutubeUrls() {
    return _eventChannel
        .receiveBroadcastStream()
        .whereType<String>()
        .map((event) => event.trim())
        .where((event) => event.isNotEmpty);
  }

  Future<String?> consumeSharedYoutubeUrl() async {
    try {
      final url = await _channel.invokeMethod<String>('consumeSharedYoutubeUrl');
      if (url == null || url.trim().isEmpty) {
        return null;
      }
      return url.trim();
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<YoutubeMp3ConversionResult> convertToMp3(String url) async {
    try {
      final result = await _channel.invokeMethod<Object?>(
        'convertToMp3',
        {'url': url},
      );

      if (result is Map<Object?, Object?>) {
        return YoutubeMp3ConversionResult.fromMap(result);
      }

      return YoutubeMp3ConversionResult.error(
        'The converter returned an invalid response.',
      );
    } on PlatformException catch (error) {
      return YoutubeMp3ConversionResult.error(
        error.message ?? 'Platform error while converting YouTube to MP3.',
      );
    } on MissingPluginException {
      return YoutubeMp3ConversionResult.error(
        'The Android ytmp3 integration is not available on this platform.',
      );
    }
  }
}
