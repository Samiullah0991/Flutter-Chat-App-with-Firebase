import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../providers/auth_provider.dart';
import '../models/contact.dart';
import '../services/db_service.dart';
import '../services/navigation_service.dart';
import 'conversation_page.dart';

class SearchPage extends StatefulWidget {
  final double height;
  final double width;

  const SearchPage({Key? key, required this.height, required this.width}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late AuthProvider _auth;
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthProvider>(context);

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildUserSearchField(),
          _buildUsersListView(),
        ],
      ),
    );
  }

  Widget _buildUserSearchField() {
    return Container(
      height: widget.height * 0.08,
      width: widget.width,
      padding: EdgeInsets.symmetric(vertical: widget.height * 0.02),
      child: TextField(
        autocorrect: false,
        style: TextStyle(color: Colors.white),
        onChanged: (_input) => setState(() => _searchText = _input),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.white),
          labelStyle: TextStyle(color: Colors.white),
          labelText: "Search",
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildUsersListView() {
    return StreamBuilder<List<Contact>>(
      stream: DBService.instance.getUsersInDB(_searchText),
      builder: (_context, _snapshot) {
        if (_snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        } else if (_snapshot.hasError) {
          return _buildErrorWidget();
        } else if (_snapshot.hasData) {
          var _usersData = _snapshot.data!;
          _usersData.removeWhere((_contact) => _contact.id == _auth.user!.uid);
          return _buildUserList(_usersData);
        } else {
          return _buildNoDataWidget();
        }
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return SpinKitWanderingCubes(color: Colors.blue, size: 50.0);
  }

  Widget _buildErrorWidget() {
    return Text("Error occurred while loading data.");
  }

  Widget _buildNoDataWidget() {
    return Text("No users found.");
  }

  Widget _buildUserList(List<Contact> usersData) {
    return Container(
      height: widget.height * 0.75,
      child: ListView.builder(
        itemCount: usersData.length,
        itemBuilder: (BuildContext _context, int _index) {
          var _userData = usersData[_index];
          var _recipientID = _userData.id;
          var _isUserActive = !_userData.lastseen.toDate().isBefore(
            DateTime.now().subtract(Duration(hours: 1)),
          );
          return ListTile(
            onTap: () => _navigateToConversationPage(_userData),
            title: Text(_userData.name),
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(_userData.image ?? ''),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                _isUserActive
                    ? Text("Active Now", style: TextStyle(fontSize: 15))
                    : Text("Last Seen", style: TextStyle(fontSize: 15)),
                _isUserActive
                    ? Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(100),
                  ),
                )
                    : Text(
                  timeago.format(_userData.lastseen.toDate()),
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToConversationPage(Contact userData) {
    DBService.instance.createOrGetConversation(
      _auth.user!.uid,
      userData.id,
          (String conversationID) => NavigationService.instance.navigateToRoute(
        MaterialPageRoute(builder: (_context) {
          return ConversationPage(
            conversationID,
            userData.id,
            userData.name,
            userData.image,
          );
        }),
      ),
    );
  }
}
