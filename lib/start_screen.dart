import 'dart:convert';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ping_pong_table/add_point_screen.dart';
import 'package:ping_pong_table/bluetooth_bloc/bluetooth_bloc.dart';
import 'package:ping_pong_table/main.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class StartScreen extends StatefulWidget {
  final HomePageState homePageState;
  const StartScreen({super.key, required this.homePageState});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  int? level;
  bool isEasy = false;
  bool isIntermediate = false;
  bool isProfessional = false;
  int started = 0;
  bool bluetoothConnected = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isEasy = level == 0;
    isIntermediate = level == 1;
    isProfessional = level == 2;

    return BlocBuilder<BluetoothBloc, BluetoothBlocState>(
      builder: (context, state) {
        /// This has to happen only once per app
        Future _initSpeech() async {
          _speechToText.hasPermission.then((value) {
            log("hasPermission : $value");
          });
          bool isEnabled = await _speechToText.initialize().then((value) {
            log("Speech enabled : $value");
            return value;
          });
          setState(() {
            _speechEnabled = isEnabled;
          });
        }

        Future sendCommand(int command) async {
          log("Command sent is $command");
          if (state is BluetoothConnected) {
            state.connection.output.add(utf8.encode("$command"));
            await state.connection.output.allSent;
          } else {
            ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
              content: const Text("Bluetooth Not Connected!"),
              action: SnackBarAction(
                  label: "Go to settings",
                  onPressed: () {
                    widget.homePageState.setState(() {
                      widget.homePageState.switchToIndex(1);
                    });
                  }),
            ));
          }
        }

        void _onSpeechResult(SpeechRecognitionResult result) {
          if (state is BluetoothConnected && state.connection.isConnected) {
            log("on speech result : ${result.finalResult}");
            log("on speech result words : ${result.recognizedWords}");

            String recognizedWords = result.recognizedWords;

            setState(() {
              if (recognizedWords.contains("start")) {
                started = 1;
                sendCommand.call(1);
              } else if (recognizedWords.contains("stop")) {
                started = 0;
                sendCommand.call(0);
              } else if (recognizedWords.contains("activate")) {
                if (recognizedWords.contains("easy")) {
                  level = 0;
                  sendCommand.call(2);
                } else if (recognizedWords
                    .toLowerCase()
                    .contains("intermediate")) {
                  level = 1;
                  sendCommand.call(3);
                } else if (recognizedWords
                        .toLowerCase()
                        .contains("profession") ||
                    recognizedWords.toLowerCase().contains("professional")) {
                  level = 2;
                  sendCommand.call(4);
                }
              }
            });
          } else {
            ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
              content: Text("Bluetooth Not Connected!"),
              action: SnackBarAction(
                  label: "Go to settings",
                  onPressed: () {
                    widget.homePageState.setState(() {
                      widget.homePageState.switchToIndex(1);
                    });
                  }),
            ));
          }
        }

        Future _startListening() async {
          bool available = await _speechToText.initialize(
            options: [SpeechToText.androidIntentLookup],
            onStatus: (val) {
              print("Status: $val");
              if (val.toLowerCase().contains("done")) {
                setState(() {
                  _isListening = false;
                });
              } else if (val.toLowerCase() == "notlistening") {
                setState(() {
                  _isListening = false;
                });
              }
            },
            onError: (val) => print('onError: $val'),
            // finalTimeout: const Duration(seconds: 0),
          );
          if (available) {
            setState(() => _isListening = true);
            await _speechToText.listen(
              onResult: (val) =>
                  // _text = val.recognizedWords;
                  _onSpeechResult(val),
              listenOptions: SpeechListenOptions(
                partialResults: false,
                cancelOnError: true,
                listenMode: ListenMode.dictation,
                enableHapticFeedback: true,
              ),
              listenFor: const Duration(seconds: 5),
            );
          }
        }

        Future _stopListening() async {
          await _speechToText.stop();
          setState(() {
            _isListening = false;
          });
        }

        return Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
          floatingActionButton: FloatingActionButton(
            backgroundColor: _isListening ? Colors.red : Colors.green,
            mini: true,
            onPressed: () async {
              if (_isListening) {
                await _stopListening();
              } else {
                await _startListening();
              }
            },
            child: Icon(
              _isListening ? Icons.stop : Icons.mic,
              color: Colors.white,
            ),
          ),
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue[100]!, Colors.green[100]!])),
              ),
              StreamBuilder<DatabaseEvent>(
                  stream: FirebaseDatabase.instance.ref('/app/on_off').onValue,
                  builder: (context, snapshot) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(top: 0),
                      color: Colors.transparent,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 50),
                              width: 100,
                              height: 100,
                              child: ClipOval(
                                child: TextButton.icon(
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          started == 1
                                              ? Colors.red
                                              : Colors.green)),
                                  icon: started == 1
                                      ? const Icon(
                                          Icons.stop_circle,
                                          color: Colors.white,
                                          size: 30,
                                        )
                                      : const Icon(
                                          Icons.play_circle,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                  onPressed: () {
                                    // FirebaseDatabase.instance
                                    //     .ref('/app')
                                    //     .update({"on_off": started == 1 ? 0 : 1});
                                    sendCommand(started == 1 ? 0 : 1);
                                    setState(() {
                                      started = started == 1 ? 0 : 1;
                                    });
                                  },
                                  label: Text(
                                    started == 1 ? "Stop" : "Start",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 50),
                              width: 100,
                              height: 50,
                              child: TextButton.icon(
                                style: const ButtonStyle(
                                    backgroundColor:
                                        MaterialStatePropertyAll(Colors.blue)),
                                label: const Text(
                                  "Add",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const PingPongTable()));
                                },
                                icon: const Icon(
                                  Icons.add_box,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: 80,
                              margin: const EdgeInsets.only(top: 50),
                              child: ElevatedButton(
                                onPressed: () async {
                                  // FirebaseDatabase.instance
                                  //     .ref('/app')
                                  //     .update({"level": 0});
                                  await sendCommand(2);
                                  changeLevel(0);
                                },
                                style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                  Colors.green.withOpacity(isEasy ? 1 : 0.4),
                                )),
                                child: const Text(
                                  "Easy",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: 80,
                              margin: const EdgeInsets.only(top: 50),
                              child: ElevatedButton(
                                onPressed: () async {
                                  await sendCommand(3);
                                  changeLevel(1);
                                },
                                style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                  Colors.amber
                                      .withOpacity(isIntermediate ? 1 : 0.4),
                                )),
                                child: const Text(
                                  "Intermediate",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Container(
                              height: 80,
                              width: MediaQuery.of(context).size.width * 0.5,
                              margin: const EdgeInsets.only(top: 50),
                              child: ElevatedButton(
                                onPressed: () async {
                                  await sendCommand(4);
                                  changeLevel(2);
                                },
                                style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                  Colors.red
                                      .withOpacity(isProfessional ? 1 : 0.4),
                                )),
                                child: const Text(
                                  "Professional",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Container(
                              height: 80,
                              width: MediaQuery.of(context).size.width * 0.5,
                              margin: const EdgeInsets.only(top: 50),
                              child: ElevatedButton(
                                onPressed: () async {
                                  await sendCommand(4);
                                  changeLevel(2);
                                },
                                style: const ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                  Colors.blueGrey,
                                )),
                                child: const Text(
                                  "Custom",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ],
          ),
        );
      },
    );
  }

  changeLevel(int newLevel) {
    setState(() {
      level = newLevel;
    });
  }
}
