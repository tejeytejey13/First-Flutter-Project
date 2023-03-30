import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:twitterproject/database/post.dart';
import 'package:twitterproject/database/users.dart';

class UpdatePost extends StatefulWidget {
  UpdatePost({super.key, required this.userPost});

  final Post userPost;

  @override
  State<UpdatePost> createState() => _UpdatePostState();
}

class _UpdatePostState extends State<UpdatePost> {
  late TextEditingController postCtrl;
  late TextEditingController postTimeCtrl;
  late TextEditingController postImgCtrl;
  late String imgUrl;
  late String error;

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
    print('update Download Link: $urlDownload');

    updateTweet(widget.userPost.post_id, urlDownload);
    MotionToast(
      //Duration(seconds: 3),
      primaryColor: Colors.green,
      description: Text("Tweet Successfully Updated"),
      icon: Icons.check_circle_outline_outlined,
      enableAnimation: true,
    ).show(context);

    setState(() {
      uploadTask = null;
    });
  }

  void initState() {
    postCtrl = TextEditingController(
      text: widget.userPost.postcontent,
    );
    postTimeCtrl = TextEditingController(
      text: widget.userPost.time,
    );
    imgUrl = widget.userPost.postimg;
    error = "";

    super.initState();
  }

  @override
  void dispose() {
    postCtrl.dispose();
    postTimeCtrl.dispose();
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
                  child: const Text('Upadate Tweet'),
                  onPressed: () {
                    (pickedFile != null)
                        ? uploadFile()
                        : updateNoFile(widget.userPost.post_id);
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
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              buildProgress(),
              photoIcon(),
            ],
          )
        ],
      ),
    );
  }

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
              controller: postCtrl,
              keyboardType: TextInputType.multiline,
              maxLines: 10,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "What's happening?",
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
                child: (pickedFile == null) ? checkImgVal() : imgExist(),
              ),
            ),
          ),
        ),
      );

  Widget imgExist() => Image.file(
        File(pickedFile!.path!),
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
      );

  Widget imgNotExist() => Image.network(
        widget.userPost.postimg,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
      );

  Widget imgNotExistBlank() => const CircleAvatar(
        radius: 45,
        child: Icon(
          Icons.camera_alt_outlined,
          color: Colors.transparent,
        ),
      );

  Widget checkImgVal() {
    return Container(
      width: double.infinity,
      height: 250,
      child:
          (widget.userPost.postimg == '-') ? imgNotExistBlank() : imgNotExist(),
    );
  }

  updateTweet(String id, String image) async {
    final docUser = FirebaseFirestore.instance.collection('Post').doc(id);
    docUser.update({
      'postcontent': postCtrl.text,
      'postimg': image,
    });

    Navigator.pop(context);
  }

  Future updateNoFile(String id) async {
    final docUser = FirebaseFirestore.instance.collection('Post').doc(id);
    await docUser.update({
      'postcontent': postCtrl.text,
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

  Widget iconImgExist(img) => CircleAvatar(
        radius: 45,
        backgroundImage: NetworkImage(img),
      );

  Widget iconImgNotExist() => const Icon(
        Icons.account_circle_outlined,
        color: Colors.grey,
      );

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
}
