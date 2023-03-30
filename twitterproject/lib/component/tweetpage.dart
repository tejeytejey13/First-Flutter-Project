import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:twitterproject/crudpage/addreplies.dart';
import 'package:twitterproject/crudpage/addtweets.dart';
import 'package:twitterproject/database/post.dart';
import 'package:twitterproject/database/users.dart';
import 'package:twitterproject/screen/tweetview.dart';

class TweetPage extends StatefulWidget {
  const TweetPage({
    super.key,
  });

  @override
  State<TweetPage> createState() => _TweetPageState();
}

class _TweetPageState extends State<TweetPage> {
  final user = FirebaseAuth.instance.currentUser!.uid;
  int numberOfFaves = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTweets(),
              ));
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: readUserPost(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          } else if (snapshot.hasData) {
            final users = snapshot.data!;

            return ListView(
              children: users.map(newpost).toList(),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget newpost(Post userpost) => GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TweetView(
                userPost: userpost,
              ),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 15,
            ),
            tweets(userpost),
            newbuttons(userpost),
            Divider()
          ],
        ),
      );
  var nametxtStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  Widget newbuttons(Post userpost) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 65),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    primary: Colors.grey,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  icon: const FaIcon(FontAwesomeIcons.comment, size: 20),
                  label: Text(''),
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => AddReplies(post_id: widget.userPost.post_id),
                    //   ),
                    // );
                  },
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                      primary: (!userpost.isLiked) ? Colors.grey : Colors.red,
                      splashFactory: NoSplash.splashFactory),
                  onPressed: () {
                    
                    setState(() {
                      if (!userpost.isLiked) {
                        userpost.isLiked = true;
                        updateLike(userpost.post_id, true);
                      } else {
                        userpost.isLiked = false;
                        updateLike(userpost.post_id, false);
                      }
                    });
                  },
                  icon: const FaIcon(FontAwesomeIcons.heart, size: 20),
                  label: Text(''),
                ),
              ],
            ),
          ),
          const Divider()
        ],
      );

//Adding tweets
  Widget tweets(Post userpost) => Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        userpost.postcontent,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          decorationStyle: TextDecorationStyle.wavy,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  child: (userpost.postimg != "-")
                      ? imgExist(userpost.postimg)
                      : imgNotExist(),
                ),
              ],
            ),
          ),
        ],
      );

//Calling the name of the user
  Widget buildUser(Users user) => Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: CircleAvatar(
                      radius: 27,
                      backgroundColor: Colors.white,
                      child: (user.image != "-")
                          ? iconImgExist(user.image)
                          : iconImgNotExist(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 11),
                    child: Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  Widget read(uid) {
    var collection = FirebaseFirestore.instance.collection('Users');
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: collection.doc(uid).snapshots(),
            builder: (_, snapshot) {
              if (snapshot.hasError) return Text('Error = ${snapshot.error}');

              if (snapshot.hasData) {
                final users = snapshot.data!.data();
                final newUser = Users(
                  id: users!['id'],
                  name: users['name'],
                  username: users['username'],
                  password: users['password'],
                  email: users['email'],
                  bio: users['bio'],
                  location: users['location'],
                  birthdate: users['birthdate'],
                  age: users['age'],
                  image: users['image'],
                );

                return buildUser(newUser);
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }

  Stream<List<Post>> readUserPost() =>
      FirebaseFirestore.instance.collection('Post').snapshots().map(
            (snapshot) => snapshot.docs
                .map(
                  (doc) => Post.fromJson(
                    doc.data(),
                  ),
                )
                .toList(),
          );

  updateLike(String id, bool status) {
    final docUser = FirebaseFirestore.instance.collection('Post').doc(id);
    docUser.update({
      'isLiked': status,
    });
  }

  Widget imgExist(img) => Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(width: 1.5, color: Colors.white70),
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: NetworkImage(img),
            fit: BoxFit.fill,
          ),
        ),
      );

  Widget imgNotExist() => Container();

  Widget iconImgExist(img) => CircleAvatar(
        radius: 45,
        backgroundImage: NetworkImage(img),
      );

  Widget iconImgNotExist() => const Icon(
        Icons.account_circle_outlined,
        color: Colors.grey,
      );
}
