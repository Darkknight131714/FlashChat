import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/components/loginregister.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
class LoginScreen extends StatefulWidget {
  static String id='login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showSpinner=false;
  String errorText="";
  final _auth = FirebaseAuth.instance;
  String email,password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email=value;
                },
                decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your Email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password=value;
                },
                decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your Password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              LoginRegister(color: Colors.lightBlueAccent,text: 'Login',onpressed: ()async{
                setState(() {
                  showSpinner=true;
                });
                try{
                  final newUser = await _auth.signInWithEmailAndPassword(email: email, password: password);
                  if(newUser!=null)
                    {
                      Navigator.pushNamed(context, ChatScreen.id);
                    }
                  setState(() {
                    showSpinner=false;
                  });
                }
                catch(e){
                  setState(() {
                    errorText=e.toString();
                    showSpinner=false;
                  });
                }
              },),
              Text(errorText,style: TextStyle(color: Colors.red,fontWeight: FontWeight.w700),),
            ],
          ),
        ),
      ),
    );
  }
}
