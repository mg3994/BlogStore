import '../../sm.dart';

class SessionState {
  final String clientId;
  final String? idToken;
  final String? uid;
  final String? email;
  final bool isLoggedIn;

  const SessionState({
    required this.clientId,
    this.idToken,
    this.uid,
    this.email,
    this.isLoggedIn = false,
  });

  bool get isGuest => !isLoggedIn || idToken == null || idToken == 'guest_session';
}

class SessionManagerService {
  final Signal<SessionState> _sessionSignal;

  SessionManagerService({String? initialClientId})
      : _sessionSignal = signal<SessionState>(
          SessionState(
            clientId: initialClientId ?? 'client_${DateTime.now().millisecondsSinceEpoch}',
            isLoggedIn: false,
          ),
        );

  ReadonlySignal<SessionState> get sessionSignal => _sessionSignal;

  String get clientId => _sessionSignal.value.clientId;

  bool get isLoggedIn => _sessionSignal.value.isLoggedIn;

  String? get idToken => _sessionSignal.value.idToken;

  void login({
    required String idToken,
    String? uid,
    String? email,
  }) {
    _sessionSignal.value = SessionState(
      clientId: _sessionSignal.value.clientId,
      idToken: idToken,
      uid: uid,
      email: email,
      isLoggedIn: true,
    );
  }

  void logout() {
    _sessionSignal.value = SessionState(
      clientId: _sessionSignal.value.clientId,
      idToken: 'guest_session',
      uid: 'guest',
      email: null,
      isLoggedIn: false,
    );
  }
}
