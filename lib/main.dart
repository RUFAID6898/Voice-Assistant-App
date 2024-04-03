import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: VoiceAssistantScreen(),
    );
  }
}

class VoiceAssistantScreen extends StatefulWidget {
  @override
  _VoiceAssistantScreenState createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _text = '';
  String _response = '';
  TextEditingController _reminderController = TextEditingController();
  stt.SpeechToText get speechToText => _speechToText;

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    initSpeechRecognizer();
  }

  void initSpeechRecognizer() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        print('Speech recognition status: $status');
      },
      onError: (error) => print('Speech recognition error: $error'),
    );
    if (available) {
      print('Speech recognition initialized successfully');
    } else {
      print('Speech recognition initialization failed');
    }
  }

  void startListening() {
    if (_speechToText.isAvailable && !_speechToText.isListening) {
      _speechToText.listen(
        onResult: (result) => setState(() {
          _text = result.recognizedWords;
        }),
      );
      setState(() {
        _isListening = true;
      });
    }
  }

  void stopListening() {
    _speechToText.stop();
  }

  void setReminder(String task, DateTime time) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(time);
    await prefs.setString('reminder_$formattedTime', task);
    setState(() {
      _response = 'Reminder set for $formattedTime: $task';
    });
  }

  void searchWeb(String query) {
    setState(() {
      _response = 'Searching the web for: $query';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Assistant'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_text),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _reminderController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                    labelText: 'Enter Reminder'),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              // crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setReminder(_reminderController.text, DateTime.now());
                  },
                  child: const Text('Set Reminder'),
                ),
                ElevatedButton(
                  onPressed: () {
                    searchWeb(_text);
                  },
                  child: const Text('Search Web'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                if (!_isListening) {
                  startListening();
                  setState(() {
                    _isListening = true;
                  });
                } else {
                  stopListening();
                  setState(() {
                    _isListening = false;
                  });
                }
              },
              child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
            ),
            Text(_response),
          ],
        ),
      ),
    );
  }
}
