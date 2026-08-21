import '../../sm.dart';

enum ToastType { success, error, info }

class ToastMessage {
  final String id;
  final String message;
  final ToastType type;
  final DateTime timestamp;

  const ToastMessage({
    required this.id,
    required this.message,
    this.type = ToastType.success,
    required this.timestamp,
  });
}

class ToastNotificationService {
  final Signal<ToastMessage?> _toastSignal = signal<ToastMessage?>(null);

  ReadonlySignal<ToastMessage?> get currentToastSignal => _toastSignal;

  void showToast(String message, {ToastType type = ToastType.success}) {
    _toastSignal.value = ToastMessage(
      id: 'toast_${DateTime.now().millisecondsSinceEpoch}',
      message: message,
      type: type,
      timestamp: DateTime.now(),
    );
  }

  void clearToast() {
    _toastSignal.value = null;
  }
}
