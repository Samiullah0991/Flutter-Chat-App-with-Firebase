import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/db_service.dart';
import '../services/media_service.dart';
import '../services/cloud_storage_service.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ConversationPage extends StatefulWidget {
  final String conversationID;
  final String receiverID;
  final String receiverImage;
  final String receiverName;

  ConversationPage(this.conversationID, this.receiverID, this.receiverName, this.receiverImage);

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  late GlobalKey<FormState> _formKey;
  late ScrollController _listViewController;
  String _messageText = "";

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _listViewController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(31, 31, 31, 1.0),
        title: Text(widget.receiverName),
      ),
      body: ChangeNotifierProvider.value(
        value: Provider.of<AuthProvider>(context),
        child: _conversationPageUI(),
      ),
    );
  }

  Widget _conversationPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        final _auth = Provider.of<AuthProvider>(_context);
        return Stack(
          children: <Widget>[
            _messageListView(_auth),
            Align(
              alignment: Alignment.bottomCenter,
              child: _messageField(_context, _auth),
            ),
          ],
        );
      },
    );
  }

  Widget _messageListView(AuthProvider _auth) {
    return Container(
      height: _deviceHeight * 0.75,
      width: _deviceWidth,
      child: StreamBuilder<Conversation>(
        stream: DBService.instance.getConversation(widget.conversationID),
        builder: (BuildContext _context, AsyncSnapshot<Conversation> _snapshot) {
          if (_snapshot.connectionState == ConnectionState.waiting) {
            return _loadingWidget();
          } else if (_snapshot.hasError) {
            return _errorWidget();
          } else if (_snapshot.hasData) {
            var _conversationData = _snapshot.data!;
            return _messageList(_conversationData, _auth);
          } else {
            return _noConversationWidget();
          }
        },
      ),
    );
  }

  Widget _messageList(Conversation conversationData, AuthProvider _auth) {
    Timer(
      Duration(milliseconds: 50),
          () => _listViewController.jumpTo(_listViewController.position.maxScrollExtent),
    );
    return ListView.builder(
      controller: _listViewController,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      itemCount: conversationData.messages.length,
      itemBuilder: (BuildContext _context, int _index) {
        var _message = conversationData.messages[_index];
        bool _isOwnMessage = _message.senderID == _auth.user?.uid;
        return _messageListViewChild(_isOwnMessage, _message);
      },
    );
  }

  Widget _messageListViewChild(bool isOwnMessage, Message message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          !isOwnMessage ? _userImageWidget() : Container(),
          SizedBox(width: _deviceWidth * 0.02),
          message.type == MessageType.Text
              ? _textMessageBubble(isOwnMessage, message.content, message.timestamp)
              : _imageMessageBubble(isOwnMessage, message.content, message.timestamp),
        ],
      ),
    );
  }

  Widget _userImageWidget() {
    double _imageRadius = _deviceHeight * 0.05;
    return Container(
      height: _imageRadius,
      width: _imageRadius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(500),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(widget.receiverImage),
        ),
      ),
    );
  }

  Widget _textMessageBubble(bool isOwnMessage, String message, Timestamp timestamp) {
    List<Color> _colorScheme = isOwnMessage
        ? [Colors.blue, Color.fromRGBO(42, 117, 188, 1)]
        : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];
    return Container(
      height: _deviceHeight * 0.08 + (message.length / 20 * 5.0),
      width: _deviceWidth * 0.75,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: _colorScheme,
          stops: [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(message),
          Text(
            timeago.format(timestamp.toDate()),
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _imageMessageBubble(bool isOwnMessage, String imageURL, Timestamp timestamp) {
    List<Color> _colorScheme = isOwnMessage
        ? [Colors.blue, Color.fromRGBO(42, 117, 188, 1)]
        : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];
    DecorationImage _image = DecorationImage(image: NetworkImage(imageURL), fit: BoxFit.cover);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: _colorScheme,
          stops: [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            height: _deviceHeight * 0.30,
            width: _deviceWidth * 0.40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: _image,
            ),
          ),
          Text(
            timeago.format(timestamp.toDate()),
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _messageField(BuildContext context, AuthProvider _auth) {
    return Container(
      height: _deviceHeight * 0.08,
      decoration: BoxDecoration(
        color: Color.fromRGBO(43, 43, 43, 1),
        borderRadius: BorderRadius.circular(100),
      ),
      margin: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.04, vertical: _deviceHeight * 0.03),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _messageTextField(),
            _sendMessageButton(context, _auth),
            _imageMessageButton(_auth),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth * 0.55,
      child: TextFormField(
        validator: (_input) {
          if (_input!.isEmpty) {
            return "Please enter a message";
          }
          return null;
        },
        onChanged: (_input) {
          setState(() {
            _messageText = _input;
          });
        },
        cursorColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Type a message",
        ),
        autocorrect: false,
      ),
    );
  }

  Widget _sendMessageButton(BuildContext context, AuthProvider _auth) {
    return Container(
      height: _deviceHeight * 0.05,
      width: _deviceHeight * 0.05,
      child: IconButton(
        icon: Icon(
          Icons.send,
          color: Colors.white,
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            DBService.instance.sendMessage(
              widget.conversationID,
              Message(
                content: _messageText,
                senderID: _auth.user!.uid,
                timestamp: Timestamp.now(),
                type: MessageType.Text,
              ),
            );
            _formKey.currentState!.reset();
            FocusScope.of(context).unfocus();
          }
        },
      ),
    );
  }

  Widget _imageMessageButton(AuthProvider _auth) {
    return Container(
      height: _deviceHeight * 0.05,
      width: _deviceHeight * 0.05,
      child: IconButton(
        icon: Icon(
          Icons.camera_alt,
          color: Colors.white,
        ),
        onPressed: () async {
          var _image = await MediaService.instance.getImageFromLibrary();
          if (_image != null) {
            var _result = await CloudStorageService.instance.uploadMediaMessage(_auth.user!.uid, _image);
            var _imageURL = await _result.ref.getDownloadURL();
            await DBService.instance.sendMessage(
              widget.conversationID,
              Message(
                content: _imageURL,
                senderID: _auth.user!.uid,
                timestamp: Timestamp.now(),
                type: MessageType.Image,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _loadingWidget() {
    return Center(
      child: SpinKitWanderingCubes(
        color: Colors.white,
        size: 50.0,
      ),
    );
  }

  Widget _errorWidget() {
    return Center(
      child: Text(
        'Error loading conversation',
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _noConversationWidget() {
    return Center(
      child: Text(
        'No conversation found',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
