import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                onChanged: (val) => setState(() => _email = val),
              ),
              SizedBox(height: 24),
              if (_message != null)
                Text(
                  _message!,
                  style: TextStyle(
                    color: _isSuccess ? Colors.green : Colors.red,
                  ),
                ),
              SizedBox(height: 16),
              ElevatedButton(
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Reset Password'),
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                            _message = null;
                          });
                          String? result =
                              await authService.resetPassword(_email);
                          setState(() {
                            _isLoading = false;
                            if (result == null) {
                              _isSuccess = true;
                              _message =
                                  'Password reset email sent. Check your inbox.';
                            } else {
                              _isSuccess = false;
                              _message = result;
                            }
                          });
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
