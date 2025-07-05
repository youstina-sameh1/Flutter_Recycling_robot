import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? file;
  List messege = [];
  openGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      file = File(photo.path);
    }
  }

  TextEditingController textEditingController = TextEditingController();
add() {
  if (file != null) {
    if (textEditingController.text.isNotEmpty) {
      setState(() {
        messege.add({
          "text": textEditingController.text,
          "sender": true,
          "image": file,
          "hasImage": true,
        });
      });
      Gemini gemini = Gemini.instance;
      gemini.textAndImage(
          text: textEditingController.text,
          images: [file!.readAsBytesSync()]
      ).then((value) {
        setState(() {
          
          String responseText = value?.content?.parts?.last.text ?? 'No response available';
          messege.add({
            "text": responseText,
            "sender": false,
            "image": null,
            "hasImage": false,
          });
        });
      });
      file = null;
    }
  } else {
    if (textEditingController.text.isNotEmpty) {
      setState(() {
        messege.add({
          "text": textEditingController.text,
          "sender": true,
          "image": null,
          "hasImage": false, 
        });
      });
      Gemini gemini = Gemini.instance;
      gemini.text(textEditingController.text).then(
        (value) {
          setState(() {
            
            String responseText = value?.output ?? 'No response available';
            messege.add({
              "text": responseText,
              "sender": false,
              "image": null,
              "hasImage": false,
            });
          });
        },
      );
    }
  }
  setState(() {
     textEditingController.text = "";
  });
}

  String keyapi = "AIzaSyDEyjXVQyYLdOVZqV-zFVsYy95hdP_0ii8";
  @override
  void initState() {
    Gemini.init(apiKey: keyapi);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Recycling Robot",
          style: TextStyle(
            fontWeight: FontWeight.bold,color: Colors.white
          ),
        ),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: ListView.builder(
                itemBuilder: (context, index) => Messege(
                    sender: messege[index]["sender"],
                    text: messege[index]["text"],
                    hasImage: messege[index]["hasImage"],
                    image: messege[index]["image"]),
                itemCount: messege.length,
              ),
            )),
            Container(
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                      width: 270,
                      height: 40,
                      child: TextFormField(
                        controller: textEditingController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.all(8.0),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                                borderRadius: BorderRadius.circular(50)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                ),
                                borderRadius: BorderRadius.circular(50))),
                        style: TextStyle(color: Colors.black),
                      )),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      add();
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      openGallery();
                    },
                    child: Icon(
                      Icons.add_photo_alternate,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

extension on Part {
  get text => null;
}

class Messege extends StatelessWidget {
  final bool sender;
  final bool hasImage;
  final String text;
  final File? image;
  const Messege(
      {super.key,
      required this.sender,
      required this.text,
      required this.hasImage,
      required this.image});

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: (sender) ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          width: 300,
          child: Column(
            crossAxisAlignment:
                (sender) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (sender && hasImage)
                Container(
                    height: 200,
                    width: 300,   
                    decoration: BoxDecoration(
                        image:(image!=null)? DecorationImage(image: FileImage(image!)):null,
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15))),
              Container(
                constraints: BoxConstraints(maxWidth: (sender) ? 250 : 300),
                decoration: BoxDecoration(
                  color: (sender) ? Color.fromARGB(255, 0, 0, 0) : Colors.grey,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.all(8.0),
                child: Text(
                  text,
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}