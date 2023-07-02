import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:influencer_map/res/strings.dart';
import 'package:influencer_map/res/textStyles.dart';
import '../src/constants.dart' as constants;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Inquiry extends StatelessWidget {
  TextEditingController inputController1 = TextEditingController();
  TextEditingController inputController2 = TextEditingController();
  Inquiry({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(MyStrings.sendInquiry),
        titleTextStyle: MyTextStyles.big,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              onPressed: () {
                if (_isInputExists()) {
                  postInquiry(inputController1.text, inputController2.text);
                  Navigator.pop(context);
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                            content: const Text(
                                MyStrings.enterEmailAndInquiryDetails),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(MyStrings.confirmed))
                            ],
                          ));
                }
              },
              child: const Text(MyStrings.done))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          direction: Axis.vertical,
          spacing: 16,
          children: [
            SizedBox(
              width: deviceWidth - 32,
              child: TextField(
                maxLength: 320,
                controller: inputController1,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: MyStrings.emailToReceiveReply,
                    border: OutlineInputBorder(),
                    counterText: ""),
                textInputAction: TextInputAction.next,
              ),
            ),
            SizedBox(
              width: deviceWidth - 32,
              child: TextField(
                maxLength: 2000,
                controller: inputController2,
                minLines: 5,
                maxLines: 10,
                decoration: const InputDecoration(
                    labelText: MyStrings.inquiryContent,
                    border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isInputExists() {
    if (inputController1.text == "") {
      return false;
    } else if (inputController2.text == "") {
      return false;
    } else {
      return true;
    }
  }

  void postInquiry(String email, String content) async {
    Uri url = constants.inquiryDBUri;

    var response =
        await http.post(url, headers: constants.inquiryPostHeaders, body: '''{
        "parent": {
          "database_id": "${dotenv.env['INQUIRY_DB_ID']}"
         },
         "properties": {
          "content": {
            "rich_text": [
              {
                "text": {
                  "content": "$content"
                }
              }
            ]
          },
          "email": {
            "title": [
              {
                "text": {
                  "content": "$email"
                }
              }
            ]
          }
         }
      }''');
  }
}
