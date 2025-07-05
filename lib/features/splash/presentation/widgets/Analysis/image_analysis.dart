import 'dart:io';
import 'package:first_app_robot/features/splash/presentation/widgets/GeminiAI/gemini.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class Analysis extends StatefulWidget {
  final File image;
  const Analysis({super.key, required this.image});

  @override
  _AnalysisState createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> {
  List<String> suggestions = ["", ""];
  File? selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedImage = widget.image;
  }

  Future<void> onView() async {
    setState(() {
      isLoading = true;
    });
    try {
      if (selectedImage == null) {
        setState(() {
          suggestions = ["No image selected.", ""];
        });
        return;
      }
      await dotenv.load(fileName: 'assets/.env');
      String? apiKey = dotenv.env['API_KEY'];
      if (apiKey == null) {
        setState(() {
          suggestions = ["API Key not found.", ""];
        });
        return;
      }

      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final bytes = await widget.image.readAsBytes();

      final content = [
        Content.text(""),
        Content.data('image/png', bytes),
      ];

      final res = await model.generateContent(content);
      String? analysisResult = res.text;
      if (analysisResult == null || analysisResult.isEmpty) {
      setState(() {
        suggestions = ["No response from Gemini AI.", ""];
      });
      return;
    }

   
    final recyclingPrompt =
        "Suggest a creative recycling idea for the following object: $analysisResult";

    final recyclingResponse = await model.generateContent(
      [Content.text(recyclingPrompt)],
    );

    setState(() {
      suggestions = [
        analysisResult, 
        recyclingResponse.text ?? "No recycling idea generated." 
      ];
    });
  } catch (e) {
    setState(() {
      suggestions = ["Error: ${e.toString()}", ""];
    });
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

  Future<void> onPickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Image Source'),
          children: [
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context,
                    await picker.pickImage(source: ImageSource.camera));
              },
              child: const Text('Camera'),
            ),
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context,
                    await picker.pickImage(source: ImageSource.gallery));
              },
              child: const Text('Gallery'),
            ),
          ],
        );
      },
    );
    

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
        suggestions = ["", ""];
      });
    }
  }
  Future<void> sendToGeminiForRecycling(String inputText) async {
  setState(() {
    isLoading = true;
  });
  try {
    await dotenv.load(fileName: 'assets/.env');
    String? apiKey = dotenv.env['API_KEY']!;

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    final content = [Content.text(inputText)];
    final res = await model.generateContent(content);

    setState(() {
      suggestions[1] = res.text ?? "No suggestion received.";
    });
  } catch (e) {
    setState(() {
      suggestions[1] = "Error: ${e.toString()}";
    });
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Results & Suggestions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 34, 52, 51),
        foregroundColor: const Color.fromARGB(159, 255, 255, 255),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/RR.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (selectedImage != null)
                Image.file(selectedImage!, height: 200, fit: BoxFit.cover),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SuggestionCard(
                    label: 'Analysis',
                    suggestion: suggestions[0],
                    width: 180,
                    height: 320,
                    isLoading: isLoading,
                  ),
                  SuggestionCard(
                    label: 'Suggestion',
                    suggestion: suggestions[1],
                    width: 180,
                    height: 320,
                    isLoading: isLoading,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: onView,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(200, 14, 61, 53),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Show Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: (){
                  if (suggestions[0].isNotEmpty) {
      sendToGeminiForRecycling(suggestions[0]);
    } else {
      setState(() {
        suggestions[1] = "No analysis text to send.";
      });
    }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(200, 14, 61, 53),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Recycle Suggestion',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: onPickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(200, 14, 61, 53),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'New Request',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyApp()),
                      );
                    },
                    icon: const Icon(Icons.auto_fix_high_outlined,
                        color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.home, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SuggestionCard extends StatelessWidget {
  final String label;
  final String suggestion;
  final double width;
  final double height;
  final bool isLoading;

  const SuggestionCard({
    super.key,
    required this.label,
    required this.suggestion,
    required this.width,
    required this.height,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  suggestion,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
