import 'package:permission_handler/permission_handler.dart';

/// Microphone permission. The Arabic rationale is shown by the UI *before*
/// [requestMic] is called (Constitution Principle VII: never block the user).
abstract class PermissionService {
  Future<bool> micGranted();
  Future<bool> requestMic();
}

class PermissionHandlerService implements PermissionService {
  @override
  Future<bool> micGranted() async => Permission.microphone.isGranted;

  @override
  Future<bool> requestMic() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
}
