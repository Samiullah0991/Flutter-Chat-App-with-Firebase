import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/message.dart';
import '../providers/auth_provider.dart';
import '../services/db_service.dart';
import '../services/navigation_service.dart';
import '../models/conversation.dart';
import '../pages/conversation_page.dart';

class RecentConversationsPage extends StatelessWidget {
  final double height;
  final double width;

  const RecentConversationsPage({Key? key, required this.height, required this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: _buildConversationsListViewWidget(),
    );
  }

  Widget _buildConversationsListViewWidget() {
    return Builder(
      builder: (BuildContext context) {
        final authProvider = Provider.of<AuthProvider>(context);
        return Container(
          height: height,
          width: width,
          child: StreamBuilder<List<ConversationSnippet>>(
            stream: authProvider.user != null
                ? DBService.instance.getUserConversations(authProvider.user!.uid)
                : null,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingIndicator();
              } else if (snapshot.hasError) {
                return _buildErrorWidget();
              } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                return _buildNoConversationsWidget();
              } else {
                final conversations = snapshot.data!;
                return _buildConversationsList(conversations);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: SpinKitWanderingCubes(
        color: Colors.blue,
        size: 50.0,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Text(
        'Error loading data',
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildNoConversationsWidget() {
    return Center(
      child: Text(
        'No Conversations Yet!',
        style: TextStyle(color: Colors.white30, fontSize: 15.0),
      ),
    );
  }

  Widget _buildConversationsList(List<ConversationSnippet> conversations) {
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return ListTile(
          onTap: () {
            _navigateToConversationPage(context, conversation);
          },
          title: Text(conversation.name),
          subtitle: Text(conversation.type == MessageType.Text
              ? conversation.lastMessage
              : 'Attachment: Image'),
          leading: _buildUserImage(conversation.image),
          trailing: _buildListTileTrailingWidgets(conversation.timestamp),
        );
      },
    );
  }

  Widget _buildUserImage(String imageUrl) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(imageUrl),
        ),
      ),
    );
  }

  Widget _buildListTileTrailingWidgets(Timestamp lastMessageTimestamp) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          'Last Message',
          style: TextStyle(fontSize: 15),
        ),
        Text(
          timeago.format(lastMessageTimestamp.toDate()),
          style: TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  void _navigateToConversationPage(BuildContext context, ConversationSnippet conversation) {
    NavigationService.instance.navigateToRoute(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return ConversationPage(
            conversation.conversationID,
            conversation.id,
            conversation.name,
            conversation.image,
          );
        },
      ),
    );
  }
}
