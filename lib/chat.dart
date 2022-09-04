import 'package:shechat/firebase/messaging.dart';
import 'package:shechat/models/messages_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class Chat extends StatefulWidget {
  final String user;

  const Chat({super.key, required this.user});

  @override
  ChatState createState() {
    return ChatState();
  }
}

class ChatState extends State<Chat> {
  TextEditingController _messageController = TextEditingController();
  ScrollController _controller = ScrollController();
  late io.Socket socket;

  void _sendMessage() {
    String messageText = _messageController.text.trim();
    _messageController.text = '';
    debugPrint(messageText);
    if (messageText != '') {
      var messagePost = {
        'message': messageText,
        'sender': widget.user,
        'recipient': 'chat',
        'time': DateTime.now().toUtc().toString().substring(0, 16)
      };
      socket.emit('chat', messagePost);
    }
  }

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _controller = ScrollController();
    initSocket();
    WidgetsBinding.instance.addPostFrameCallback((_) => {
          _controller.animateTo(
            0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
          )
        });
  }

  Future<void> initSocket() async {
    debugPrint('Connecting to chat service');
    String? registrationToken = await Messaging.getToken();
    socket = io.io('https://5bd0-202-142-81-2.in.ngrok.io', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'userName': widget.user, 'registrationToken': registrationToken}
    });
    socket.connect();
    socket.onConnect((_) {
      debugPrint('connected to websocket');
    });
    socket.on('newChat', (message) {
      debugPrint(message);
      setState(() {
        MessagesModel.messages.add(message);
      });
    });
    socket.on('allChats', (messages) {
      debugPrint(messages);
      setState(() {
        MessagesModel.messages.addAll(messages);
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.maybeOf(context)!.size;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: size.width * 0.60,
              child: const Text(
                'She Chat',
                style: TextStyle(fontSize: 15, color: Colors.white),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 60,
            width: size.width,
            child: ListView.builder(
              controller: _controller,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              reverse: true,
              cacheExtent: 1000,
              itemCount: MessagesModel.messages.length,
              itemBuilder: (BuildContext context, int index) {
                var message = MessagesModel
                    .messages[MessagesModel.messages.length - index - 1];
                return (message['sender'] == widget.user)
                    ? ChatBubble(
                        clipper:
                            ChatBubbleClipper1(type: BubbleType.sendBubble),
                        alignment: Alignment.topRight,
                        margin: const EdgeInsets.only(top: 5, bottom: 5),
                        backGroundColor: Colors.yellow[100],
                        child: Container(
                          constraints:
                              BoxConstraints(maxWidth: size.width * 0.7),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('@${message['time']}',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 10)),
                              Text('${message['message']}',
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 16))
                            ],
                          ),
                        ),
                      )
                    : ChatBubble(
                        clipper:
                            ChatBubbleClipper1(type: BubbleType.receiverBubble),
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.only(top: 5, bottom: 5),
                        backGroundColor: Colors.grey[100],
                        child: Container(
                          constraints:
                              BoxConstraints(maxWidth: size.width * 0.7),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${message['sender']} @${message['time']}',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 10)),
                              Text('${message['message']}',
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 16))
                            ],
                          ),
                        ),
                      );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: 60,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: size.width * 0.80,
                    padding: const EdgeInsets.only(left: 10, right: 5),
                    child: TextField(
                      controller: _messageController,
                      cursorColor: Colors.black,
                      decoration: const InputDecoration(
                        hintText: "Message",
                        labelStyle:
                            TextStyle(fontSize: 15, color: Colors.black),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        disabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        counterText: '',
                      ),
                      style: const TextStyle(fontSize: 15),
                      keyboardType: TextInputType.text,
                      maxLength: 500,
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.20,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.pinkAccent),
                      onPressed: () {
                        _sendMessage();
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
