import 'package:flutter/material.dart';
import 'package:taketest/data/question.dart';

class McqQ extends StatefulWidget {
  final Question question;

  final void Function(String) onChange;
  final int qNo;

  const McqQ(
      {@required this.question, @required this.onChange, @required this.qNo});

  @override
  _McqQState createState() => _McqQState();
}

class _McqQState extends State<McqQ> {
  String groupValue = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.0),
          color: Colors.white,
          border: Border.all(width: 1.0, color: const Color(0xff707070)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('${widget.qNo} '),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Text(
                    widget.question.qText,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            for (int index = 0; index < widget.question.options.length; index++)
              RadioListTile<String>(
                activeColor: Colors.green,
                title: Text('${widget.question.options[index]}'),
                value: widget.question.options[index],
                groupValue: groupValue,
                onChanged: (selectedAnswer) {
                  setState(() {
                    groupValue = selectedAnswer;
                  });

                  widget.onChange(groupValue);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class TextQ extends StatelessWidget {
  final int qNo;
  final String qText;
  final void Function(String) onChanged;

  const TextQ(
      {@required this.qNo, @required this.qText, @required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.0),
          color: Colors.white,
          border: Border.all(width: 1.0, color: const Color(0xff707070)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('$qNo '),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Text(
                    qText,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              decoration: InputDecoration(hintText: 'Write Your Answer Here'),
              maxLines: null,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
