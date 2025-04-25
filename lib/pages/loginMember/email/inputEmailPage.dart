import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/pages/loginMember/email/sentEmailPage.dart';
import 'package:readr/pages/loginMember/serviceTermsPage.dart';

class InputEmailPage extends StatefulWidget {
  @override
  State<InputEmailPage> createState() => _InputEmailPageState();
}

class _InputEmailPageState extends State<InputEmailPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_checkEmailValidity);
  }

  @override
  void dispose() {
    _controller.removeListener(_checkEmailValidity);
    _controller.dispose();
    super.dispose();
  }

  void _checkEmailValidity() {
    final isValid = isEmail(_controller.text);
    if (isValid != _isEmailValid) {
      setState(() {
        _isEmailValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'email'.tr,
          style: TextStyle(
            color: Theme.of(context).extension<CustomColors>()!.primary700!,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).extension<CustomColors>()!.primary700!,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isEmailValid && !_isSending
                ? () async {
                    setState(() {
                      _isSending = true;
                    });
                    final email = _controller.text;
                    try {
                      // Check if email exists in Firebase Auth
                      List<String> signInMethods = await FirebaseAuth.instance
                          .fetchSignInMethodsForEmail(email);

                      if (signInMethods.isEmpty) {
                        // New user: Navigate to ServiceTermsPage
                        Get.to(() => const ServiceTermsPage(), arguments: {
                          'email': email,
                        });
                      } else {
                        // Existing user: Send email directly and go to SentEmailPage
                        bool isSuccess =
                            await LoginHelper().signInWithEmailAndLink(
                          email,
                          Get.find<EnvironmentService>().config.authlink,
                        );
                        if (isSuccess && mounted) {
                          // Use off to replace current page
                          Get.off(() => SentEmailPage(email));
                        } else if (mounted) {
                          Fluttertoast.showToast(msg: "Email寄送失敗");
                        }
                      }
                    } on FirebaseAuthException catch (e) {
                      // Handle Firebase specific errors (e.g., invalid-email)
                      print('Firebase Auth Error checking email: $e');
                      Fluttertoast.showToast(
                          msg: "檢查 Email 時發生錯誤: ${e.message}");
                    } catch (e) {
                      // Handle other errors (e.g., network)
                      print('Error checking/sending email: $e');
                      Fluttertoast.showToast(msg: "發生錯誤，請稍後再試");
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isSending = false;
                        });
                      }
                    }
                  }
                : null,
            child: Text(
              'send'.tr,
              style: TextStyle(
                color: _isEmailValid
                    ? Theme.of(context).extension<CustomColors>()!.blue!
                    : Theme.of(context).extension<CustomColors>()!.primary300!,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _buildBody(context),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 24,
        ),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: _controller,
          autocorrect: false,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(12.0),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).extension<CustomColors>()!.primary700!,
                width: 1.0,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).extension<CustomColors>()!.primary200!,
                width: 1.0,
              ),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).extension<CustomColors>()!.primary200!,
                width: 1.0,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        // 電子郵件格式驗證提示
        Row(
          children: [
            Icon(
              Icons.check_circle,
              size: 18,
              color: _isEmailValid
                  ? Colors.blue
                  : Theme.of(context).extension<CustomColors>()!.primary400!,
            ),
            const SizedBox(width: 8),
            Text(
              'emailFormatValid'.tr,
              style: TextStyle(
                fontSize: 13,
                color: _isEmailValid
                    ? Colors.blue
                    : Theme.of(context).extension<CustomColors>()!.primary500!,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Text(
          'inputEmailPageBodyText'.tr,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).extension<CustomColors>()!.primary500!,
            fontWeight: FontWeight.w400,
          ),
        )
      ],
    );
  }

  bool isEmail(String input) => EmailValidator.validate(input);
}
