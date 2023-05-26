import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:intl/intl.dart';

class SmartReplyPage extends StatefulWidget {
  @override
  _SmartReplyPageState createState() => _SmartReplyPageState();
}

class _SmartReplyPageState extends State<SmartReplyPage> {
  final smartReply = SmartReply();
  bool isEnter = false;
  final TextEditingController _controller = TextEditingController();

  List<String> _suggestions = [];
  int getTimeStamp() {
    var now = DateTime.now().millisecondsSinceEpoch;

    return now;
  }

  void _generateReplies(String message) async {
    try {
      int timeStamp = getTimeStamp();
      _suggestions.clear();
      smartReply.addMessageToConversationFromLocalUser(message, timeStamp);
      final response = await smartReply.suggestReplies();
      for (final suggestion in response.suggestions) {
        setState(() {
          _suggestions.add(suggestion);
        });
        print('suggestion: $suggestion');
        print(timeStamp.toString());
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    smartReply.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Reply'),
      ),
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(40.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter a message',
              ),
              onSubmitted: (message) {
                if (message.isEmpty) {
                  setState(() {
                    _suggestions.clear();
                  });
                } else {
                  _generateReplies(message);
                  isEnter = true;
                  _controller.clear();
                }
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          isEnter
              ? Text(
                  'Suggested Replies',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                )
              : Text(''),
          SizedBox(
            height: 10,
          ),
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: _suggestions.length,
              itemBuilder: (BuildContext context, int index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  title: Text(suggestion),
                  subtitle: Divider(
                    color: Colors.grey,
                    thickness: 1.0,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
