import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:twitterproject/database/replies.dart';
import 'package:twitterproject/database/users.dart';

class AddReplies extends StatefulWidget {
  const AddReplies({super.key, required this.post_id});

  final String post_id;
  @override
  State<AddReplies> createState() => _AddRepliesState();
}

class _AddRepliesState extends State<AddReplies> {
  var _image;
  var imagePicker;
  var type;

  late TextEditingController repCtrl;
  late TextEditingController repTimeCtrl;
  late TextEditingController repImgCtrl;

  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  Future uploadFile() async {
    final path = 'files/${generateRandomString(5)}';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);

    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link: $urlDownload');

    repTweets(urlDownload);

    setState(() {
      uploadTask = null;
    });
  }

  void initState() {
    repCtrl = TextEditingController();
    repTimeCtrl = TextEditingController();
    repImgCtrl = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    repCtrl.dispose();
    repImgCtrl.dispose();
    repTimeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.close,
            size: 24.0,
          ),
          label: const Text(''),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Reply'),
                  onPressed: () {
                    uploadFile();
                  },
                ),
              ),
            ],
          )
        ],
      ),
      body: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              multitext(),
              addimage(),
              Divider(),
              buildProgress(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              photoIcon(),
              //cameraIcon(),
            ],
          )
        ],
      ),
    );
  }

  final user = FirebaseAuth.instance.currentUser!;
  Widget multitext() => Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: read(user.uid),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(70, 46, 15, 0),
            child: TextField(
              controller: repCtrl,
              keyboardType: TextInputType.multiline,
              maxLines: 10,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Add another Tweet",
              ),
            ),
          ),
        ],
      );

  Widget addimage() => Padding(
        padding: const EdgeInsets.only(bottom: 200),
        child: Container(
          child: Center(
            child: GestureDetector(
              onTap: () {
                selectFile();
              },
              child: Container(
                width: 310,
                height: 310,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.transparent),
                child: (pickedFile == null) ? imgNotExist() : imgExist(),
              ),
            ),
          ),
        ),
      );

  Widget photoIcon() => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () {
              selectFile();
            },
            icon: const Icon(
              Icons.photo_outlined,
              size: 24.0,
            ),
            label: const Text(''),
          ),
        ],
      );

  Widget imgExist() => Image.file(
        File(pickedFile!.path!),
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
      );

  Widget imgNotExist() => Icon(
        Icons.camera_enhance_outlined,
      );

  Future repTweets(urlDownload) async {
    final docTweet = FirebaseFirestore.instance.collection('Replies').doc();

    final newPost = Replies(
      time: repTimeCtrl.text,
      reply_id: widget.post_id,
      repcontent: repCtrl.text,
      repimg: urlDownload,
      isLiked: false,
    );

    final json = newPost.toJson();
    await docTweet.set(json);

    setState(() {
      repTimeCtrl.text = "";
      repCtrl.text = "";
      pickedFile = null;
    });

    Navigator.pop(context);
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;

          return SizedBox(
            height: 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey,
                  color: Colors.green,
                ),
                Center(
                  child: Text(
                    '${(100 * progress).roundToDouble()}%',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          );
        } else {
          return const SizedBox(
            height: 50,
          );
        }
      });
  Widget buildUser(Users user) => CircleAvatar(
        child:
            (user.image != "-") ? iconImgExist(user.image) : iconImgNotExist(),
      );
  Widget read(uid) {
    var collection = FirebaseFirestore.instance.collection('Users');
    return Column(
      children: [
        SizedBox(
          height: 30,
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

  Widget iconImgExist(img) => CircleAvatar(
        radius: 45,
        backgroundImage: NetworkImage(img),
      );

  Widget iconImgNotExist() => const Icon(
        Icons.account_circle_outlined,
        color: Colors.grey,
      );
}
