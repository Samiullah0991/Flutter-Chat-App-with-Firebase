import 'package:flutter/material.dart';

import './profile_page.dart';
import './recent_conversations_page.dart';
import './search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late double _height;
  late double _width;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: const Text("Chatify"),
        bottom: _buildTabBar(),
      ),
      body: _buildTabBarView(),
    );
  }

  TabBar _buildTabBar() {
    return TabBar(
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.blue,
      labelColor: Colors.blue,
      controller: _tabController,
      tabs: const [
        Tab(
          icon: Icon(
            Icons.people_outline,
            size: 25,
          ),
        ),
        Tab(
          icon: Icon(
            Icons.chat_bubble_outline,
            size: 25,
          ),
        ),
        Tab(
          icon: Icon(
            Icons.person_outline,
            size: 25,
          ),
        ),
      ],
    );
  }

  TabBarView _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        SearchPage(height: _height, width: _width),
        RecentConversationsPage(height: _height, width: _width),
        ProfilePage(height: _height, width: _width),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
