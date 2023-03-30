import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:twitterproject/crudpage/addreplies.dart';
import 'package:twitterproject/database/post.dart';
import 'package:twitterproject/database/replies.dart';
import 'package:twitterproject/database/users.dart';

class TweetView extends StatefulWidget {
  const TweetView({super.key, required this.userPost});

  final Post userPost;

  @override
  State<TweetView> createState() => _TweetViewState();
}

class _TweetViewState extends State<TweetView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        bottomOpacity: 0.0,
        elevation: 0.0,
        title: const Text(
          'Tweets',
          style: TextStyle(color: Colors.grey),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.grey,
          ),
        ),
      ),
      body: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              userpostdetails(widget.userPost)
            ],
          ),
        ],
      ),
    );
  }

  Widget userpostdetails(Post userPost) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 15,
          ),
          tweets(widget.userPost),
          newbuttons(widget.userPost),
          Divider(),
          fetchComments(),
        ],
      );

  Widget tweets(Post userPost) => Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    userPost.postcontent,
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
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(width: 1.5, color: Colors.white70),
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(userPost.postimg),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
        ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddReplies(post_id: widget.userPost.post_id),
                      ),
                    );
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

  updateLike(String id, bool status) {
    final docUser = FirebaseFirestore.instance.collection('Replies').doc(id);
    docUser.update({
      'isLiked': status,
    });
  }

  Widget fetchComments() {
    return StreamBuilder<List<Replies>>(
      stream: readUserReplies(widget.userPost.post_id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong! ${snapshot.error}');
        } else if (snapshot.hasData) {
          final users = snapshot.data!;

          return ListView(
            shrinkWrap: true,
            children: users.map(usercommenterline).toList(),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  final user = FirebaseAuth.instance.currentUser!;

  Widget usercommenterline(Replies userComment) => Stack(
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
                        userComment.repcontent,
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
                  child: (userComment.repimg != "-")
                      ? imgExist(userComment.repimg)
                      : imgNotExist(),
                ),
              ],
            ),
          ),
        ],
      );

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

  Stream<List<Replies>> readUserReplies(id) => FirebaseFirestore.instance
      .collection('Replies')
      .where('post_id', isEqualTo: id)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => Replies.fromJson(
                doc.data(),
              ),
            )
            .toList(),
      );

  var boldtxtStyle = const TextStyle(
    fontWeight: FontWeight.bold,
  );

  Widget buildTweets(Users user) => Container(
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
                  // CircleAvatar(
                  //   backgroundColor: Colors.white,
                  //   radius: 30,
                  //   child: CircleAvatar(
                  //     radius: 27,
                  //     backgroundColor: Colors.white,
                  //     child: (user.image != "-")
                  //         ? iconImgExist(user.image)
                  //         : iconImgNotExist(),
                  //   ),
                  // ),
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
  Widget readTweets(uid) {
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

                return buildTweets(newUser);
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }
}
