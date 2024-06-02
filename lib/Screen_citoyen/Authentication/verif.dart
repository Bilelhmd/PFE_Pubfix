import 'package:email_auth/email_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Reset'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await sendVerificationCode(_emailController.text);
              },
              child: const Text('Send Verification Code'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendVerificationCode(String email) async {
    try {
      EmailAuth emailAuth = EmailAuth(sessionName: "Your App Name");
      bool result = await emailAuth.sendOtp(recipientMail: email);
      if (result) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => VerificationScreen(email: email)));
      } else {
        print('Failed to send verification code');
        _showDialog('Failed to send verification code');
      }
    } catch (e) {
      _showDialog('Error sending verification code: $e');
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Password Reset'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({super.key, required this.email});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Verification Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Verification Code'),
            ),
            TextFormField(
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await verifyCodeAndResetPassword(widget.email,
                    _codeController.text, _newPasswordController.text);
              },
              child: const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> verifyCodeAndResetPassword(
      String email, String code, String newPassword) async {
    try {
      EmailAuth emailAuth = EmailAuth(sessionName: "Your App Name");
      bool result = emailAuth.validateOtp(recipientMail: email, userOtp: code);
      if (result) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updatePassword(newPassword);
          _showDialog('Password reset successfully');
        } else {
          _showDialog('No user logged in');
        }
      } else {
        _showDialog('Invalid verification code');
      }
    } catch (e) {
      _showDialog('Error resetting password: $e');
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Password Reset'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
