import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:auto_route/auto_route.dart';
import 'package:readr/helpers/router/router.dart';

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final TextEditingController _controller = TextEditingController();
  final _textFieldFocusNode = FocusNode();

  @override
  void initState() {
    _controller.text = "";
    _controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        shadowColor: Colors.white,
        backgroundColor: Colors.white,
        title: const Text(
          '註冊 / 登入會員',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.only(top: 40, left: 40, right: 40),
      physics: MediaQuery.of(context).orientation == Orientation.portrait
          ? const NeverScrollableScrollPhysics()
          : null,
      children: [
        _facebookButton(),
        const SizedBox(
          height: 12,
        ),
        _googleButton(),
        const SizedBox(
          height: 12,
        ),
        _appleButton(),
        const SizedBox(
          height: 24,
        ),
        Row(
          children: const [
            Expanded(
              child: Divider(
                color: Colors.black12,
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Text(
              '或',
              softWrap: true,
              style: TextStyle(color: Colors.black38),
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(
              child: Divider(
                color: Colors.black12,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 24,
        ),
        const Center(
          child: Text(
            '以 Email 繼續',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: _controller,
          focusNode: _textFieldFocusNode,
          validator: (value) {
            if (value != null) {
              if (!isEmail(value)) {
                return '請輸入有效的 Email 地址';
              }
            }
            return null;
          },
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(12.0),
            hintText: 'readr@gmail.com',
            hintStyle: TextStyle(
              color: Colors.black26,
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black87, width: 1.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black26, width: 1.0),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black26, width: 1.0),
            ),
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        OutlinedButton(
          onPressed: isEmail(_controller.text)
              ? () {
                  AutoRouter.of(context)
                      .push(SendEmailRoute(email: _controller.text));
                }
              : null,
          child: const Text('下一步'),
          style: OutlinedButton.styleFrom(
            textStyle: const TextStyle(fontSize: 16),
            fixedSize: const Size(double.infinity, 48),
            primary: Colors.black,
            backgroundColor: isEmail(_controller.text)
                ? hightLightColor
                : const Color.fromRGBO(224, 224, 224, 1),
            onSurface: Colors.black26,
            side: BorderSide(
              color: isEmail(_controller.text) ? Colors.black : Colors.black26,
            ),
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        _statement(),
      ],
    );
  }

  bool isEmail(String input) => EmailValidator.validate(input);

  Widget _facebookButton() {
    return OutlinedButton.icon(
      onPressed: () {
        context.popRoute(true);
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(
          color: Colors.black,
          width: 1,
        ),
        fixedSize: const Size(double.infinity, 48),
      ),
      icon: const FaIcon(
        FontAwesomeIcons.facebookSquare,
        size: 18,
        color: Color.fromRGBO(59, 89, 152, 1),
      ),
      label: const Text(
        '以 Facebook 帳號繼續',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _googleButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: const BorderSide(
          color: Colors.black,
          width: 1,
        ),
        fixedSize: const Size(double.infinity, 48),
      ),
      icon: SvgPicture.asset(
        googleLogoSvg,
        width: 16,
        height: 16,
      ),
      label: const Text(
        '以 Google 帳號繼續',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _appleButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: const BorderSide(
          color: Colors.black,
          width: 1,
        ),
        fixedSize: const Size(double.infinity, 48),
      ),
      icon: const FaIcon(
        FontAwesomeIcons.apple,
        size: 18,
        color: Colors.black,
      ),
      label: const Text(
        '以 Apple 帳號繼續',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _statement() {
    String html =
        "<div style='text-align:center'>繼續使用代表您同意與接受</div><div style='text-align:center'>READr 的<a href='https://www.readr.tw/privacy-rule'>《服務條款》</a>及<a href='https://www.readr.tw/privacy-rule'>《隱私政策》</div>";
    return HtmlWidget(
      html,
      customStylesBuilder: (element) {
        if (element.localName == 'a') {
          return {
            'text-decoration-color': 'rgba(0, 9, 40, 0.3)',
            'color': 'rgba(0, 9, 40, 0.3)',
            'text-decoration-thickness': '100%',
            'text-align': 'center',
          };
        }
        return null;
      },
      textStyle: const TextStyle(
        fontSize: 13,
        color: Colors.black38,
      ),
    );
  }
}
