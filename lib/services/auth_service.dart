import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sends an OTP to the supplied phone number.
  ///
  /// [onCodeSent] receives the verification ID and SMS resend token.
  /// [onVerificationCompleted] is called when Firebase can automatically
  /// verify the phone number.
  /// [onVerificationFailed] is called when verification fails.
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(PhoneAuthCredential credential)
        onVerificationCompleted,
    required void Function(FirebaseAuthException error) onVerificationFailed,
    void Function(String verificationId)? onCodeAutoRetrievalTimeout,
    int? forceResendingToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: forceResendingToken,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout:
          onCodeAutoRetrievalTimeout ?? (_) {},
    );
  }

  /// Signs the customer in using the OTP received by SMS.
  ///
  /// If the phone number is new, Firebase automatically creates
  /// the customer account.
  Future<User?> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final result = await _auth.signInWithCredential(credential);

    return result.user;
  }

  /// Signs the customer in with a Firebase phone credential.
  Future<User?> signInWithCredential(
    PhoneAuthCredential credential,
  ) async {
    final result = await _auth.signInWithCredential(credential);
    return result.user;
  }

  User? get currentUser => _auth.currentUser;

  Future<void> logout() async {
    await _auth.signOut();
  }
}
