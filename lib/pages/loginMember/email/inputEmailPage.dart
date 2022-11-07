import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/pages/loginMember/email/sentEmailPage.dart';

class InputEmailPage extends StatefulWidget {
  @override
  State<InputEmailPage> createState() => _InputEmailPageState();
}

class _InputEmailPageState extends State<InputEmailPage> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            onPressed: () async {
              if (_formKey.currentState!.validate() && !_isSending) {
                _isSending = true;
                bool isSuccess = await LoginHelper().signInWithEmailAndLink(
                  _controller.text,
                  Get.find<EnvironmentService>().config.authlink,
                );
                if (isSuccess) {
                  Get.off(() => SentEmailPage(_controller.text));
                } else {
                  Fluttertoast.showToast(
                    msg: "emailDeliveryFailed".tr,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    fontSize: 16.0,
                  );
                }
                _isSending = false;
              }
            },
            child: Text(
              'send'.tr,
              style: TextStyle(
                color: Theme.of(context).extension<CustomColors>()!.blue!,
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
        Form(
          key: _formKey,
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.disabled,
            controller: _controller,
            autocorrect: false,
            validator: (value) {
              if (value != null) {
                if (value.isEmpty) {
                  return 'inputEmailPageEmptyHint'.tr;
                } else if (!isEmail(value)) {
                  return 'inputEmailPageErrorHint'.tr;
                }
              }
              return null;
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(12.0),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color:
                      Theme.of(context).extension<CustomColors>()!.primary700!,
                  width: 1.0,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color:
                      Theme.of(context).extension<CustomColors>()!.primaryLv6!,
                  width: 1.0,
                ),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color:
                      Theme.of(context).extension<CustomColors>()!.primaryLv6!,
                  width: 1.0,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Text(
          'inputEmailPageBodyText'.tr,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).extension<CustomColors>()!.primaryLv3!,
            fontWeight: FontWeight.w400,
          ),
        )
      ],
    );
  }

  bool isEmail(String input) => EmailValidator.validate(input);
}
