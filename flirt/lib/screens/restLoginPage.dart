import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/authService.dart';
import './restHomePage.dart';
import './restRegisterPage.dart';
import './home.dart';

class RestLogin extends StatefulWidget {
  @override
  _RestLoginState createState() => _RestLoginState();
}

class _RestLoginState extends State<RestLogin> {
  @override
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Admin',
            style: TextStyle(
              color: Colors.orange[400],
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.grey[850],
          leading: Icon(Icons.restaurant),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.only(top: 70),
          child: Center(
            child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Login",
                      style: TextStyle(fontSize: 32),
                    ),
                    SizedBox(height: 20),
                    Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Container(
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: TextField(
                                  decoration:
                                      InputDecoration(labelText: 'username'),
                                  controller: usernameController,
                                ),
                              ),
                              SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: TextField(
                                  obscureText: true,
                                  decoration:
                                      InputDecoration(labelText: 'Password'),
                                  controller: passwordController,
                                ),
                              ),
                            ],
                          ),
                        )),
                    SizedBox(height: 20),
                    SizedBox(
                        height: 60,
                        width: MediaQuery.of(context).size.width,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: Colors.lightBlueAccent,
                          child: Text('Login', style: TextStyle(fontSize: 25)),
                          onPressed: () {
                            loggingIn(usernameController.text,
                                passwordController.text);
                          },
                        )),
                    SizedBox(height: 20),
                    FlatButton(
                        onPressed: () {}, child: Text('Forget Password')),
                    SizedBox(height: 5),
                    FlatButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      RestRegister()));
                        },
                        child: Text('Register')),
                  ],
                )),
          ),
        )));
  }

  loggingIn(username, password) async {
    try {
      final result = await AuthService().restLogin(username, password);
      print(result);
      if (result['success']) {
        final token = result['token'];
        SharedPreferences restPref = await SharedPreferences.getInstance();
        await restPref.setString('token', token);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => RestaurantHome(restPref)));
      } else {
        await _showMyDialog(result['msg']);
      }
    } catch (err) {
      throw err;
    }
  }

  Future<void> _showMyDialog(result) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(result),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
