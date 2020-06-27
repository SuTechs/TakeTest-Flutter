import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taketest/TestScreen.dart';
import 'package:taketest/data/question.dart';
import 'package:taketest/finished.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Take Test',
      home: Home(),
      routes: {
        'FinishedTest': (_) => TestFinishedScreen(),
      },
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _testRef = Firestore.instance.collection("Tests");

  final _formKey = GlobalKey<FormState>();

  String validatingMessage = '';

  @override
  Widget build(BuildContext context) {
    String name, email, quizID;
    return Scaffold(
      backgroundColor: Color(0xff21254A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 400,
            color: Colors.white24,
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TutorPoint',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  ///Name Field
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Name',
                    ),
                    maxLength: null,
                    validator: (value) {
                      if (value.trim().length == 0)
                        return 'Name can\'t be empty.';
                      return null;
                    },
                    onSaved: (value) => name = value,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      if (_.trim().length != 0)
                        FocusScope.of(context).nextFocus();
                    },
                  ),

                  ///Email Field
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(hintText: 'Email'),
                    maxLength: null,
                    validator: (value) {
                      if (value.trim().isEmpty) return 'Email can\'t be empty.';
                      return null;
                    },
                    onSaved: (value) => email = value,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      if (_.trim().length != 0)
                        FocusScope.of(context).nextFocus();
                    },
                  ),

                  /// Quiz id
                  TextFormField(
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: 'Test ID'),
                    validator: (value) {
                      if (value.length != 6) return 'Invalid ID';
                      return null;
                    },
                    onSaved: (value) => quizID = value,
                    textInputAction: TextInputAction.done,
                  ),

                  Text(
                    validatingMessage,
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),

                  /// Take Test Button
                  TakeTestButton(
                    onTap: () async {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();

                        var p = await _testRef.document(quizID).get();
                        if (p.exists) {
                          print('hello i exist');
                          setState(() {
                            validatingMessage = '';
                          });
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => Center(
                                    child: CircularProgressIndicator(),
                                  ));

                          int duration = p.data['durationMinutes'];

                          _testRef
                              .document(quizID)
                              .collection('Questions')
                              .getDocuments()
                              .then((documents) {
                            List<Question> q = [];
                            for (var v in documents.documents)
                              q.add(
                                Question(
                                  id: v.data['id'],
                                  type: v.data['type'],
                                  qText: v.data['qText'],
                                  options: v.data['options'],
                                ),
                              );

                            Timestamp createdOn = Timestamp.now();
                            _testRef
                                .document(quizID)
                                .collection('Responses')
                                .document('${createdOn.seconds}$name$email')
                                .setData({
                              'name': name,
                              'email': email,
                              'createdOn': createdOn,
                            }).then((value) {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TestScreen(
                                    durationInMinutes: duration,
                                    questions: q,
                                    responseRef: _testRef
                                        .document(quizID)
                                        .collection('Responses')
                                        .document(
                                            '${createdOn.seconds}$name$email'),
                                  ),
                                ),
                              );
                            });
                          });
                        } else
                          setState(() {
                            validatingMessage = 'ID is not correct';
                          });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Take Test Button
class TakeTestButton extends StatelessWidget {
  final void Function() onTap;
  const TakeTestButton({@required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          height: 50,
          margin: EdgeInsets.symmetric(horizontal: 60),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Color.fromRGBO(49, 39, 79, 1),
          ),
          child: Center(
            child: Text(
              "Take Test",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
