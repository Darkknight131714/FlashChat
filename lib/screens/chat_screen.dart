import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
final _firestore= Firestore.instance;
FirebaseUser loggedInUser;
class ChatScreen extends StatefulWidget {
  static String id='chat';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  String messageText;
  final _auth = FirebaseAuth.instance;
  void getCurrentUser()async{
    try{
      final user=await _auth.currentUser();
      if(user!=null)
      {
        loggedInUser=user;
      }
    }
    catch(e)
    {
      print(e);
    }

  }
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messages').add(
                        {
                          'text': messageText,
                          'sender': loggedInUser.email,
                        }
                      );
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasData){return Center(child: CircularProgressIndicator(backgroundColor: Colors.lightBlueAccent,),);}
        final messages = snapshot.data.documents.reversed;
        List<MessageBubble> messageBubbles=[];
        for(var message in messages){
          final messageText=message.data['text'];
          final messageSender=message.data['sender'];
          final currentUser=loggedInUser.email;
          final messageBubble=MessageBubble(text: messageText,sender: messageSender,isMe: currentUser==messageSender,);
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
            children: messageBubbles,
          ),
        );

      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text,sender;
  final bool isMe;
  MessageBubble({this.text,this.sender,this.isMe});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: [
          Text(sender,style: TextStyle(fontSize: 12,color: Colors.black54),),
          Material(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(isMe?30:0),bottomLeft: Radius.circular(30),bottomRight: Radius.circular(30),topRight: Radius.circular(isMe?0:30)),
            elevation: 5,
            color:isMe? Colors.lightBlueAccent:Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                child: Text('$text',style: TextStyle(
                    fontSize: 15,
                  color: isMe?Colors.white:Colors.black54,
                ),
                ),
              )
          ),
        ],
      ),
    );;
  }
}
