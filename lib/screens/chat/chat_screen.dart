import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emajlis/models/message_model.dart';
import 'package:emajlis/models/message_thread_model.dart';
import 'package:emajlis/screens/profile/profile_information_screen.dart';
import 'package:emajlis/services/message_api.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatefulWidget {
  final MessageThreadModel message;

  const ChatScreen({
    this.message,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final df = new DateFormat('hh:mm a');
  TextEditingController textController = TextEditingController();

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        backgroundColor: appBodyGrey,
        elevation: 0,
        leadingWidth: 65,
        centerTitle: false,
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileInformationScreen(
                  isFromChatScreen: true,
                  memberId: widget.message.otherMemberId.toString(),
                ),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: black,
                ),
                child: Image.network(
                  widget.message.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 5),
              Flexible(
                child: Text(
                  widget.message.memberName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: StreamBuilder(
                  stream: MessageApi.getMessages(widget.message.threadName),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                      default:
                        if (snapshot.hasError) {
                          return Text('Something Went Wrong Try later');
                        } else {
                          List<DocumentSnapshot> docs = snapshot.data.docs;
                          final messages = docs
                              .map((data) => MessageModel.fromSnapshot(data))
                              .toList();

                          return messages.isEmpty
                              ? Text('Say Hi..')
                              : ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  reverse: true,
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    final item = messages[index];
                                    return chatItem(item);
                                  },
                                );
                        }
                    }
                  },
                ),
              ),
            ),
          ),
          _bulidMessageComposer(),
        ],
      ),
    );
  }

  Widget chatItem(MessageModel chat) {
    bool isMe = chat.fromId == widget.message.myMemberId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: isMe ? appBlack : appBodyGrey,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 15.0,
          ),
          margin: isMe
              ? EdgeInsets.only(top: 8, bottom: 8, left: 100, right: 20)
              : EdgeInsets.only(top: 8, bottom: 8, right: 100, left: 20),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              chat.message,
              style: TextStyle(color: isMe ? appwhite : appBlack),
            ),
          ),
        ),
        Container(
          padding:
              isMe ? EdgeInsets.only(right: 20) : EdgeInsets.only(left: 20),
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
           // timeago.format(chat.createdDate),
             df.format(chat.createdDate),
            style: n_9grey(),
          ),
        ),
      ],
    );
  }

  Widget _bulidMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      height: 70.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35.0),
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              cursorColor: appGrey,
              controller: textController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type something',
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              onSend();
            },
            child: Container(
              padding: EdgeInsets.all(15.0),
              height: 60.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 7,
                    color: appBlack,
                    offset: Offset(0, 0),
                  )
                ],
                color: Theme.of(context).primaryColor,
              ),
              child: Center(
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onSend() async {
    if (textController.text.trim().isNotEmpty) {
      final filter = ProfanityFilter();
      if (!filter.hasProfanity(textController.text.trim())) {
        MessageApi.saveMessage(
          widget.message.otherMemberId.toString(),
          textController.text.trim(),
        );
        textController.clear();
      } else {
        List<String> words = filter.getAllProfanity(textController.text.trim());
        warning(
          context,
          "Message contains profanity words of " + words.join(', '),
        );
      }
    }
  }
}
