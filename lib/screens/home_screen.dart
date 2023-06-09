import 'dart:io';

import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool textScanning = false;
  bool generatingQuiz = false;

  XFile? imageFile;

  String scannedText = "";
  String generatedQuiz = "";
  String testType = "Identification";

  int numberOfQuestions = 1;

  final List<String> testTypes = <String>[
    'Identification',
    'True or False',
    'Multiple Choice'
  ];

  late TextEditingController _openAITextController;
  late TextEditingController _numberOfQuestionsController;

  @override
  void initState() {
    super.initState();
    _openAITextController = TextEditingController();
    _numberOfQuestionsController = TextEditingController();
  }

  @override
  void dispose() {
    _openAITextController.dispose();
    _numberOfQuestionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Quiz Vision"),
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Test Type",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: testType,
                  underline: Container(
                    height: 2,
                    color: Colors.grey[600],
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      testType = value!;
                    });
                  },
                  items:
                      testTypes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(
                  height: 20,
                ),
                // const Text(
                //   "Number of Questions",
                //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // ),
                // SizedBox(
                //   width: 50,
                //   height: 40,
                //   child: TextField(
                //     controller: _numberOfQuestionsController,
                //     keyboardType: TextInputType.number,
                //     onChanged: (String? value) {
                //       setState(() {
                //         numberOfQuestions = int.tryParse(value!) ?? 0;
                //       });
                //     },
                //     decoration: const InputDecoration(
                //       border: OutlineInputBorder(),
                //     ),
                //   ),
                // ),
                const SizedBox(
                  height: 20,
                ),
                if (textScanning) const CircularProgressIndicator(),
                if (!textScanning && imageFile == null)
                  Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey[300]!,
                  ),
                if (imageFile != null) Image.file(File(imageFile!.path)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.grey,
                            shadowColor: Colors.grey[400],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          onPressed: () {
                            getImage(ImageSource.gallery);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.image,
                                  size: 30,
                                ),
                                Text(
                                  "Gallery",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[600]),
                                )
                              ],
                            ),
                          ),
                        )),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.grey,
                            shadowColor: Colors.grey[400],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          onPressed: () {
                            getImage(ImageSource.camera);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.camera_alt,
                                  size: 30,
                                ),
                                Text(
                                  "Camera",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[600]),
                                )
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                generatingQuiz
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          generateQuiz(
                              scannedText, testType, numberOfQuestions);
                        },
                        child: const Text("Generate Quiz"),
                      ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  generatedQuiz,
                  style: const TextStyle(fontSize: 20),
                )
              ],
            )),
      )),
    );
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          textScanning = true;
          imageFile = pickedImage;
        });

        getRecognisedText(pickedImage);
      }
    } catch (e) {
      setState(() {
        textScanning = false;
        imageFile = null;
        scannedText = "Error occured while scanning";
      });
    }
  }

  void getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();

    RecognizedText recognisedText = await textDetector.processImage(inputImage);
    await textDetector.close();

    scannedText = "";

    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = "$scannedText${line.text}\n";
      }
    }

    setState(() {
      textScanning = false;
    });
  }

  Future<void> generateQuiz(
      String learningMaterials, String testType, int numberOfQuestions) async {
    setState(() {
      generatingQuiz = true;
    });

    String prompt = "";

    switch (testType) {
      case 'Identification':
        prompt = '''
Create an quiz where the students need to identify the terms being described.

Follow the format
Question:
Answer:

The answer must be a key term from the learning materials.
''';
        break;
      case 'True or False':
        prompt = '''
Create a True or False quiz.

Follow the format
Question:
Answer:
''';
        break;
      case 'Multiple Choice':
        prompt = '''
Create a Multiple Choice quiz.

Follow the format
Question:
Choices:
A.
B.
C.
D.
Answer:
''';
        break;
    }

    prompt += '''
Include the answers.

Use this text as the basis:
$learningMaterials
''';

    OpenAICompletionModel completion = await OpenAI.instance.completion.create(
      model: "text-davinci-003",
      prompt: prompt,
      maxTokens: 3000,
      temperature: 0.5,
      n: 1,
      echo: false,
    );

    setState(() {
      generatedQuiz = completion.choices.first.text;
      generatingQuiz = false;
    });
  }
}
