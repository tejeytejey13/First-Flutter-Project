import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:twitterproject/component/list.dart';
import 'package:twitterproject/component/list1.dart';
import 'package:twitterproject/component/list2.dart';
import 'package:twitterproject/component/profiledrawer.dart';
import 'package:twitterproject/database/users.dart';

class TwitterDrawer extends StatelessWidget {
  const TwitterDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: const [
          ProfileDrawer(
            following: 90,
            followers: 100,
          ),
          Divider(),
          List(
            item: IconData(0xf27a, fontFamily: 'MaterialIcons'),
            text: 'Profile',
          ),
          List1(
            item: IconData(0xf1ac, fontFamily: 'MaterialIcons'),
            text: 'Account',
          ),
          List2(
            item: IconData(0xf199, fontFamily: 'MaterialIcons'),
            text: 'Log out', 
          ),
      
        ],
      ),
    );
  }
}
