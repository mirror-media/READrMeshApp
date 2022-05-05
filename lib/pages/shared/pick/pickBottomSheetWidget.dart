import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';

import 'package:readr/pages/shared/profilePhotoWidget.dart';

class PickBottomSheetWidget extends StatefulWidget {
  final ValueChanged<String> onTextChanged;
  final String? oldContent;

  const PickBottomSheetWidget({
    required this.onTextChanged,
    this.oldContent,
  });

  @override
  _PickBottomSheetWidgetState createState() => _PickBottomSheetWidgetState();
}

class _PickBottomSheetWidgetState extends State<PickBottomSheetWidget> {
  late final TextEditingController _controller;
  bool _hasInput = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.oldContent);
    if (widget.oldContent?.isNotEmpty ?? false) {
      _hasInput = true;
      widget.onTextChanged(widget.oldContent!);
    }
    _controller.addListener(() {
      // pass value back to showPickBottomSheet
      widget.onTextChanged(_controller.text);

      // check value whether is only space
      if (_controller.text.trim().isNotEmpty) {
        setState(() {
          _hasInput = true;
        });
      } else {
        setState(() {
          _hasInput = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            Row(
              children: [
                ProfilePhotoWidget(Get.find<UserService>().currentUser, 22),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    Get.find<UserService>().currentUser.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: readrBlack87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            TextField(
              minLines: 1,
              maxLines: 6,
              controller: _controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '跟大家分享你為什麼精選這篇文章...',
                hintStyle: TextStyle(color: readrBlack30),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: Text(
                  _hasInput ? '發佈' : '直接加入精選',
                  style: const TextStyle(
                    color: Colors.blue,
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context, true);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
