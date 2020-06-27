import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taketest/data/question.dart';
import 'package:taketest/qWidgets.dart';
import 'package:timer_count_down/timer_count_down.dart';

class TestScreen extends StatefulWidget {
  final List<Question> questions;
  final DocumentReference responseRef;
  final int durationInMinutes;

  const TestScreen(
      {@required this.questions,
      @required this.responseRef,
      @required this.durationInMinutes});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  Map<String, String> answers = {};

  void onQuizFinished() {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ));

    print('Answers = $answers');
    widget.responseRef.setData({'answers': answers}, merge: true).then((value) {
      Navigator.pop(context);
      Navigator.popAndPushNamed(context, 'FinishedTest');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.green,
              height: 40,
              child: Center(
                child: Countdown(
                  seconds: widget.durationInMinutes * 60 ?? 0,
                  build: (_, double time) {
                    Duration d = Duration(seconds: time.round());

                    return Text(
                      '${d.toString().split('.').first.padLeft(8, "0")}',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    );
                  },
                  interval: Duration(seconds: 1),
                  onFinished: onQuizFinished,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.questions.length + 1,
                itemBuilder: (_, index) {
                  if (index == widget.questions.length)
                    return GestureDetector(
                      onTap: onQuizFinished,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                          height: 60,
                          margin: EdgeInsets.symmetric(horizontal: 60),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.green,
                          ),
                          child: Center(
                            child: Text(
                              "Finish & Submit",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    );

                  if (widget.questions[index].type == 'MCQ')
                    return McqQ(
                      question: widget.questions[index],
                      onChange: (answer) {
                        answers['${widget.questions[index].id}'] = answer;
                      },
                      qNo: index + 1,
                    );

                  if (widget.questions[index].type == 'Text')
                    return TextQ(
                      qNo: index + 1,
                      qText: widget.questions[index].qText,
                      onChanged: (answer) {
                        answers['${widget.questions[index].id}'] = answer;
                      },
                    );

                  return Text('Error');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
