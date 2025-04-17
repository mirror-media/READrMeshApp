import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/pages/loginMember/email/sentEmailPage.dart';

class ServiceTermsPage extends StatefulWidget {
  const ServiceTermsPage({super.key});

  @override
  State<ServiceTermsPage> createState() => _ServiceTermsPageState();
}

class _ServiceTermsPageState extends State<ServiceTermsPage> {
  bool _agreed = false;
  bool _isSending = false;
  bool _isLoading = true;
  String? _termsContent;
  String? _error;
  late final String email;

  @override
  void initState() {
    super.initState();
    email = Get.arguments['email'];
    _fetchTermsContent();
  }

  Future<void> _fetchTermsContent() async {
    const termsUrl =
        'https://storage.googleapis.com/statics-mesh-tw-dev/policies/terms-of-service.html';
    const policyUrl =
        'https://storage.googleapis.com/statics-mesh-tw-dev/policies/privacy-policy.html';

    try {
      final responses = await Future.wait([
        http.get(Uri.parse(termsUrl)),
        http.get(Uri.parse(policyUrl)),
      ]);

      final termsResponse = responses[0];
      final policyResponse = responses[1];

      if (termsResponse.statusCode == 200 && policyResponse.statusCode == 200) {
        String decodedTermsHtml = utf8.decode(termsResponse.bodyBytes);
        const termsStartMarker = '精鏡傳媒股份有限公司';
        int termsStartIndex = decodedTermsHtml.indexOf(termsStartMarker);
        String processedTermsContent;
        if (termsStartIndex != -1) {
          processedTermsContent =
              '<h2>服務條款</h2>\n\n' + decodedTermsHtml.substring(termsStartIndex);
        } else {
          print('Warning: Terms start marker not found.');
          processedTermsContent = '<h2>服務條款</h2>\n\n' + decodedTermsHtml;
        }

        String decodedPolicyHtml = utf8.decode(policyResponse.bodyBytes);
        const policyStartMarker = '歡迎您光臨';
        int policyStartIndex = decodedPolicyHtml.indexOf(policyStartMarker);
        String processedPolicyContent;
        if (policyStartIndex != -1) {
          processedPolicyContent = '<h2>隱私權政策</h2>\n\n' +
              decodedPolicyHtml.substring(policyStartIndex);
        } else {
          print('Warning: Policy start marker not found.');
          processedPolicyContent = '<h2>隱私權政策</h2>\n\n' + decodedPolicyHtml;
        }

        String combinedContent = processedTermsContent +
            '\n\n<hr style="height:1px;border-width:0;color:gray;background-color:gray">\n\n' +
            processedPolicyContent;

        setState(() {
          _termsContent = combinedContent;
          _isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load content - Terms: ${termsResponse.statusCode}, Policy: ${policyResponse.statusCode}');
      }
    } catch (e) {
      print('Error fetching terms/policy: $e');
      setState(() {
        _error = '無法載入服務條款，請稍後再試。';
        _isLoading = false;
      });
    }
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                '繼續使用前，請先詳閱我們的服務條款及隱私權政策',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      Theme.of(context).extension<CustomColors>()?.primary500,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildTermsContent(),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GestureDetector(
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
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ElevatedButton(
                onPressed: _agreed
                    ? () {
                        _handleNextStep();
                      }
                    : null,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_termsContent != null) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).extension<CustomColors>()?.primary200 ??
                Colors.grey,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: Colors.black, fontSize: 14),
              child: HtmlWidget(
                _termsContent!,
              ),
            ),
          ),
        ),
      );
    }
    return const Center(child: Text('無法載入服務條款內容。')); // Fallback
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
