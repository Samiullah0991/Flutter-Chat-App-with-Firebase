import 'dart:js';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/auth_provider.dart';
import '../services/db_service.dart';
import '../models/contact.dart';

class ProfilePage extends StatelessWidget {
  final double height;
  final double width;

  const ProfilePage({Key? key, required this.height, required this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Container(
        color: Theme.of(context).backgroundColor,
        height: height,
        width: width,
        child: _buildProfilePageUI(context, authProvider),
      ),
    );
  }

  Widget _buildProfilePageUI(BuildContext context, AuthProvider authProvider) {
    return StreamBuilder<Contact>(
      stream: authProvider.user != null
          ? DBService.instance.getUserData(authProvider.user!.uid)
          : null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        } else if (snapshot.hasError) {
          return _buildErrorWidget();
        } else if (!snapshot.hasData) {
          return _buildNoDataWidget();
        } else {
          return _buildUserProfileWidget(context, snapshot.data!, authProvider);
        }
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

  Widget _buildNoDataWidget() {
    return Center(
      child: Text(
        'No user data found',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildUserProfileWidget(BuildContext context, Contact userData, AuthProvider authProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildUserImageWidget(userData.image),
          _buildUserNameWidget(userData.name),
          _buildUserEmailWidget(userData.email),
          _buildLogoutButton(authProvider),
        ],
      ),
    );
  }

  Widget _buildUserImageWidget(String? image) {
    final imageRadius = height * 0.20;
    return Container(
      height: imageRadius,
      width: imageRadius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(imageRadius),
        image: image != null
            ? DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(image),
        )
            : null,
      ),
    );
  }

  Widget _buildUserNameWidget(String userName) {
    return Text(
      userName,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white, fontSize: 30),
    );
  }

  Widget _buildUserEmailWidget(String email) {
    return Text(
      email,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white24, fontSize: 15),
    );
  }

  Widget _buildLogoutButton(AuthProvider authProvider) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) => Container(
        height: height * 0.06,
        width: width * 0.80,
        child: MaterialButton(
          onPressed: () async {
            await authProvider.logoutUser();
          },
          color: Colors.red,
          child: Text(
            "LOGOUT",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
