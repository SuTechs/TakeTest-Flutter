import 'package:flutter/cupertino.dart';

class Question {
  final String type, id, qText;
  final List<dynamic> options;

  Question(
      {@required this.type,
      @required this.id,
      @required this.qText,
      this.options});
}
