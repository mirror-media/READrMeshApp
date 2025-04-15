import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/pages/loginMember/email/sentEmailPage.dart';

class ServiceTermsPage extends StatefulWidget {
  const ServiceTermsPage({Key? key}) : super(key: key);

  @override
  State<ServiceTermsPage> createState() => _ServiceTermsPageState();
}

class _ServiceTermsPageState extends State<ServiceTermsPage> {
  bool _agreed = false;
  bool _isSending = false;
  late final String email;

  @override
  void initState() {
    super.initState();
    email = Get.arguments['email'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '服務條款',
          style: TextStyle(
            color: Theme.of(context).extension<CustomColors>()?.primary700,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Theme.of(context).extension<CustomColors>()?.primary700,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '繼續使用前，請先詳閱我們的服務條款及隱私權政策',
                style: TextStyle(
                  color:
                      Theme.of(context).extension<CustomColors>()?.primary500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context)
                              .extension<CustomColors>()
                              ?.primary200 ??
                          Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: SingleChildScrollView(
                    child: Text(
                      '服務條款標題\n\n' + '這裡放置服務條款的內容...\n' * 50,
                      style: TextStyle(
                        color: Theme.of(context)
                            .extension<CustomColors>()
                            ?.primary700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _agreed = !_agreed;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _agreed,
                      side: !_agreed
                          ? BorderSide(
                              color: Theme.of(context)
                                      .extension<CustomColors>()
                                      ?.primary200 ??
                                  Colors.grey,
                              width: 2,
                            )
                          : null,
                      onChanged: (bool? value) {
                        setState(() {
                          _agreed = value ?? false;
                        });
                      },
                      activeColor: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primary700,
                    ),
                    Text(
                      '我同意以上條款',
                      style: TextStyle(
                        color: Theme.of(context)
                            .extension<CustomColors>()
                            ?.primary700,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _agreed
                    ? () {
                        _handleNextStep();
                      }
                    : null, // Disable button if not agreed
                style: ElevatedButton.styleFrom(
                  backgroundColor: _agreed
                      ? Theme.of(context).extension<CustomColors>()?.primary700
                      : Theme.of(context).extension<CustomColors>()?.primary200,
                  minimumSize: const Size(double.infinity, 48),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
                child: Text(
                  '下一步',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: _agreed
                        ? Theme.of(context).backgroundColor
                        : Theme.of(context)
                            .extension<CustomColors>()
                            ?.primary400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleNextStep() async {
    if (_isSending) return;
    setState(() {
      _isSending = true;
    });
    bool isSuccess = await LoginHelper().signInWithEmailAndLink(
      email,
      Get.find<EnvironmentService>().config.authlink,
    );
    if (isSuccess) {
      Get.off(() => SentEmailPage(email));
    } else {
      Fluttertoast.showToast(
        msg: "emailDeliveryFailed".tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
      );
      setState(() {
        _isSending = false;
      });
    }
  }
}
