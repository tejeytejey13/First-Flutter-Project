import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:twitterproject/database/users.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController birthdatecontroller;
  late FixedExtentScrollController scrollController;
  late TextEditingController agecontroller;
  late TextEditingController usernamecontroller;
  late TextEditingController passwordcontroller;
  late TextEditingController namecontroller;
  late TextEditingController emailcontroller;
  TextEditingController textarea = TextEditingController();
  late TextEditingController locationcontroller;
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
    print('Download Link: $urlDownload');

    createUser(urlDownload);

    setState(() {
      uploadTask = null;
    });
  }

  DateTime datetime = DateTime.now();
  int index = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollController = FixedExtentScrollController(initialItem: index);
    birthdatecontroller = TextEditingController();
    agecontroller = TextEditingController();
    usernamecontroller = TextEditingController();
    passwordcontroller = TextEditingController();
    namecontroller = TextEditingController();
    emailcontroller = TextEditingController();
    textarea = TextEditingController();
    locationcontroller = TextEditingController();
    error = "";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    scrollController.dispose();
    birthdatecontroller.dispose();
    agecontroller.dispose();
    usernamecontroller.dispose();
    passwordcontroller.dispose();
    namecontroller.dispose();
    emailcontroller.dispose();
    textarea.dispose();
    locationcontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.network(
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Twitter-logo.svg/512px-Twitter-logo.svg.png?20220821125553',
          width: 30,
          height: 30,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.grey,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 35,
                ),
                const Center(
                  child: Text(
                    'Create your account',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    selectFile();
                  },
                  child: Center(
                    child: (pickedFile == null) ? imgNotExist() : imgExist(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: TextFormField(
                    validator: (value) {
                      if (value != null && value.length < 1) {
                        return 'Please Enter username';
                      } else {
                        return null;
                      }
                    },
                    controller: usernamecontroller,
                    onChanged: (content) {
                      setState(() {
                        emailcontroller.text = content;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter username',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: TextFormField(
                    validator: (value) {
                      if (value != null && value.length < 1) {
                        return 'Please Enter name';
                      } else {
                        return null;
                      }
                    },
                    controller: namecontroller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter name',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: TextFormField(
                    validator: (value) {
                      if (value != null && value.length < 1) {
                        return 'Please Enter email';
                      } else {
                        return null;
                      }
                    },
                    controller: emailcontroller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter email',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: TextFormField(
                    validator: (value) {
                      if (value != null && value.length < 1) {
                        return 'Please Enter password';
                      } else {
                        return null;
                      }
                    },
                    controller: passwordcontroller,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter password',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: TextField(
                    controller: textarea,
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Bio",
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: TextField(
                    controller: locationcontroller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter Location',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: TextField(
                    onTap: () {
                      scrollController.dispose();
                      scrollController =
                          FixedExtentScrollController(initialItem: index);
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) => CupertinoActionSheet(
                          actions: [builddatepicker()],
                          cancelButton: CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Done'),
                          ),
                        ),
                      );
                    },
                    readOnly: true,
                    controller: birthdatecontroller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter birthdate',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 310, 10),
                  child: TextField(
                    readOnly: true,
                    controller: agecontroller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Age',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        registerUser();
                      } else {}
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text(
                      'REGISTER',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                buildProgress(),
                // Text(
                //   error,
                //   style: TextStyle(
                //     color: Colors.red,
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget builddatepicker() => SizedBox(
        height: 100,
        child: CupertinoDatePicker(
          minimumYear: 1900,
          maximumYear: DateTime.now().year,
          initialDateTime: datetime,
          mode: CupertinoDatePickerMode.date,
          onDateTimeChanged: (datetime) {
            setState(() {
              this.datetime = datetime;
              final value = DateFormat('MM/dd/yyyy').format(datetime);
              birthdatecontroller.text = value;

              final int age = DateTime.now().year - datetime.year;
              agecontroller.text = age.toString();
            });
          },
        ),
      );

  Future registerUser() async {
    showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailcontroller.text.trim(),
        password: passwordcontroller.text.trim(),
      );
      uploadFile();

      setState(() {
        // MotionToast(
        //   //Duration(seconds: 3),
        //   primaryColor: Colors.green,
        //   description: Text("Successfully login"),
        //   icon: Icons.check_circle_outline_outlined,
        //   enableAnimation: true,
        // ).show(context);
        Fluttertoast.showToast(msg: "Account Successfully Created");

        error = "";
      });
    } on FirebaseAuthException catch (e) {
      print(e);
      setState(() {
        error = e.message.toString();
      });
    }

    Navigator.pop(context);
  }

  Future createUser(urlDownload) async {
    final user = FirebaseAuth.instance.currentUser!;
    final userid = user.uid;

    final docUser = FirebaseFirestore.instance.collection('Users').doc(userid);

    final newUser = Users(
      id: userid,
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

    final json = newUser.toJson();
    await docUser.set(json);

    setState(() {
      pickedFile = null;
    });

    Navigator.pop(context);
  }

  Widget imgExist() => CircleAvatar(
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

  Widget imgNotExist() => FaIcon(
        FontAwesomeIcons.usersViewfinder,
        size: 40,
      );

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
        },
      );
}
