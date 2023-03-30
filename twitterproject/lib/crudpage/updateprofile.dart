// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:twitterproject/database/users.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({
    super.key,
    required this.user,
  });

  final Users user;

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  TextEditingController textarea = TextEditingController();
  late TextEditingController namecontroller;
  late TextEditingController locationcontroller;
  late TextEditingController birthdatecontroller;
  late TextEditingController agecontroller;
  late TextEditingController biocontroller;
  late TextEditingController usernamecontroller;
  late TextEditingController emailcontroller;
  late TextEditingController passwordcontroller;
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

    updateUser(widget.user.id, urlDownload);
    MotionToast(
      //Duration(seconds: 3),
      primaryColor: Colors.green,
      description: Text("Profile Successfully Updated"),
      icon: Icons.check_circle_outline_outlined,
      enableAnimation: true,
    ).show(context);

    setState(() {
      uploadTask = null;
    });
  }

  @override
  void initState() {
    namecontroller = TextEditingController(
      text: widget.user.name,
    );
    textarea = TextEditingController(
      text: widget.user.bio,
    );
    locationcontroller = TextEditingController(
      text: widget.user.location,
    );
    imgUrl = widget.user.image;
    error = "";

    super.initState();
  }

  @override
  void dispose() {
    textarea.dispose();
    namecontroller.dispose();
    locationcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.grey,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              (pickedFile != null)
                  ? uploadFile()
                  : updateNoFile(widget.user.id);
            },
            icon: const Icon(
              Icons.save_alt_outlined,
              size: 24.0,
            ),
            label: const Text('Save'),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: ListView(
        children: [
          IconImage(),
        ],
      ),
    );
  }

  Widget Header() => Stack(
        children: [
          Container(
            height: 150,
            decoration: const BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/image_16.jpg'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Container(),
          )
        ],
      );

  Widget IconImage() => Container(
        transform: Matrix4.translationValues(0.0, -40.0, 0.0),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    selectFile();
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 45,
                    child: CircleAvatar(
                      radius: 43,
                      child: ClipOval(
                        child: (pickedFile == null)
                            ? checkImgVal()
                            : iconImgExist(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 46, 15, 0),
              child: TextField(
                controller: namecontroller,
                decoration: InputDecoration(
                  labelText: "Name",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 46, 15, 0),
              child: TextField(
                controller: textarea,
                keyboardType: TextInputType.multiline,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Bio",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 46, 15, 0),
              child: TextField(
                controller: locationcontroller,
                decoration: InputDecoration(
                  labelText: "Location",
                ),
              ),
            ),
          ],
        ),
      );

  updateUser(String id, String image) async {
    final docUser = FirebaseFirestore.instance.collection('Users').doc(id);
    docUser.update({
      'name': namecontroller.text,
      'bio': textarea.text,
      'location': locationcontroller.text,
      'image': image,
    });

    Navigator.pop(context);
  }

  Future updateNoFile(String id) async {
    final docUser = FirebaseFirestore.instance.collection('Users').doc(id);
    await docUser.update({
      'name': namecontroller.text,
      'bio': biocontroller.text,
      'location': locationcontroller.text,
    });

    Navigator.pop(context);
  }

  Widget iconImgExist() => CircleAvatar(
        radius: 40,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 42,
          backgroundImage: Image.file(
            File(pickedFile!.path!),
            fit: BoxFit.cover,
          ).image,
        ),
      );

  Widget iconImgNotExist() => CircleAvatar(
        radius: 45,
        child: Image.network(
          widget.user.image,
        ),
      );

  Widget imgNotExistBlank() => CircleAvatar(
        radius: 45,
        child: Icon(
          Icons.camera_alt_outlined,
          color: Colors.transparent,
        ),
      );

  Widget checkImgVal() {
    return CircleAvatar(
      radius: 45,
      child:
          (widget.user.image == '-') ? imgNotExistBlank() : iconImgNotExist(),
    );
  }

  Future createUser(urlDownload) async {
    final docUser = FirebaseFirestore.instance.collection('Users').doc();

    final newUser = Users(
      id: docUser.id,
      username: usernamecontroller.text,
      password: passwordcontroller.text,
      email: emailcontroller.text,
      name: namecontroller.text,
      birthdate: birthdatecontroller.text,
      age: agecontroller.text,
      bio: textarea.text,
      location: locationcontroller.text,
      image: urlDownload,
    );
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;

          return SizedBox(
            height: 50,
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
}
