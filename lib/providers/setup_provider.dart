import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/native_bridge.dart';

class SetupState {
  final SetupStep step;
  final int stepNumber;
  final int? progress;
  final String? message;
  final bool hasError;
  final String? error;
  final bool isComplete;

  SetupState({
    this.step = SetupStep.idle,
    this.stepNumber = 0,
    this.progress,
    this.message,
    this.hasError = false,
    this.error,
    this.isComplete = false,
  });

  SetupState copyWith({
    SetupStep? step,
    int? stepNumber,
    int? progress,
    String? message,
    bool? hasError,
    String? error,
    bool? isComplete,
  }) {
    return SetupState(
      step: step ?? this.step,
      stepNumber: stepNumber ?? this.stepNumber,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      hasError: hasError ?? this.hasError,
      error: error ?? this.error,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

enum SetupStep {
  idle,
  downloadingRootfs,
  extractingRootfs,
}

class SetupProvider extends ChangeNotifier {
  SetupState _state = SetupState();
  SetupState get state => _state;
  bool get isRunning => _state.step != SetupStep.idle && !_state.isComplete;

  Timer? _progressTimer;

  Future<void> runSetup() async {
    try {
      _state = _state.copyWith(
        step: SetupStep.downloadingRootfs,
        stepNumber: 1,
        message: 'Downloading Ubuntu rootfs...',
        hasError: false,
        error: null,
      );
      notifyListeners();

      // Download rootfs
      final arch = await NativeBridge.getArch();
      final rootfsUrl = _getRootfsUrl(arch);
      final filesDir = await NativeBridge.getFilesDir();
      final tarPath = '$filesDir/tmp/rootfs.tar.gz';

      _startProgressSimulation();

      // Download
      await _downloadFile(rootfsUrl, tarPath);

      _state = _state.copyWith(
        step: SetupStep.extractingRootfs,
        stepNumber: 2,
        message: 'Extracting Ubuntu rootfs...',
        progress: 0,
      );
      notifyListeners();

      // Extract
      final filesDir = await NativeBridge.getFilesDir();
      await NativeBridge.extractRootfs(tarPath: '$filesDir/tmp/rootfs.tar.gz');

      _state = _state.copyWith(
        step: SetupStep.idle,
        stepNumber: 3,
        isComplete: true,
        progress: 100,
        message: 'Setup complete!',
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        hasError: true,
        error: e.toString(),
      );
      notifyListeners();
    } finally {
      _progressTimer?.cancel();
    }
  }

  void _startProgressSimulation() {
    _progressTimer?.cancel();
    int progress = 0;
    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (progress < 90) {
        progress += 5;
        _state = _state.copyWith(progress: progress);
        notifyListeners();
      }
    });
  }

  String _getRootfsUrl(String arch) {
    const baseUrl = 'https://cdimage.ubuntu.com/ubuntu-base/releases/24.04/release/ubuntu-base-24.04.3-base-';
    switch (arch) {
      case 'aarch64':
        return '${baseUrl}arm64.tar.gz';
      case 'arm':
        return '${baseUrl}armhf.tar.gz';
      case 'x86_64':
        return '${baseUrl}amd64.tar.gz';
      default:
        return '${baseUrl}arm64.tar.gz';
    }
  }

  Future<void> _downloadFile(String url, String path) async {
    // This would use dio/http to download - for now just simulate
    await Future.delayed(const Duration(seconds: 5));
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }
}
