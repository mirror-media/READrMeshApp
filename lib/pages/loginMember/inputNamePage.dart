import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/services/memberService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputNamePage extends StatefulWidget {
  final List<String> publisherTitleList;
  const InputNamePage(this.publisherTitleList);
  @override
  _InputNamePageState createState() => _InputNamePageState();
}

class _InputNamePageState extends State<InputNamePage> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: FirebaseAuth.instance.currentUser!.displayName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        shadowColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '姓名',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate() && !_isSending) {
                try {
                  _isSending = true;
                  await MemberService().createMember();
                  final prefs = await SharedPreferences.getInstance();
                  final List<String> followingPublisherIds =
                      prefs.getStringList('followingPublisherIds') ?? [];
                  if (followingPublisherIds.isNotEmpty) {
                    AutoRouter.of(context)
                        .replace(ChooseMemberRoute(isFromPublisher: false));
                  } else {
                    AutoRouter.of(context)
                        .replace(const ChoosePublisherRoute());
                  }
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: "發生錯誤，請稍後再試",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    fontSize: 16.0,
                  );
                }
                _isSending = false;
              }
            },
            child: const Text(
              '完成註冊',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: TextFormField(
            keyboardType: TextInputType.name,
            maxLength: 20,
            autovalidateMode: AutovalidateMode.disabled,
            controller: _controller,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '請輸入姓名。';
              } else if (!_validateNickname(value)) {
                return '這個名稱目前無法使用，請使用其他名稱。';
              }
              return null;
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(12.0),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black87, width: 1.0),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black26, width: 1.0),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black26, width: 1.0),
              ),
              counterText: '',
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        const Text(
          '請輸入您想使用的公開顯示名稱，我們鼓勵您填寫真實姓名。\n字數以20字內為限。',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
            fontWeight: FontWeight.w400,
          ),
        )
      ],
    );
  }

  bool _validateNickname(String text) {
    for (var title in widget.publisherTitleList) {
      if (_equalsIgnoreCase(text, title)) {
        return false;
      }
    }
    return true;
  }

  bool _equalsIgnoreCase(String string1, String string2) {
    return string1.toLowerCase() == string2.toLowerCase();
  }
}