import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'Email'),
              validator: (val) => val!.isEmpty ? 'Enter an email' : null,
              onChanged: (val) => setState(() => _email = val),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (val) =>
                  val!.length < 6 ? 'Enter a password 6+ chars long' : null,
              onChanged: (val) => setState(() => _password = val),
            ),
            ElevatedButton(
              child: Text('Sign In'),
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isLoading = true);
                        String? result =
                            await authService.signIn(_email, _password);
                        if (result != null) {
                          setState(() {
                            _isLoading = false;
                            // Show error message
                          });
                        }
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
