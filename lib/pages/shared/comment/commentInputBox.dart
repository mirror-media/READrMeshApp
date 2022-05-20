import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';

import 'package:readr/pages/loginMember/loginPage.dart';
import 'package:readr/pages/shared/ProfilePhotoWidget.dart';

class CommentInputBox extends StatefulWidget {
  final void Function(String text) onPressed;
  final bool isSending;
  final String? oldContent;
  final ValueChanged<String> onTextChanged;
  final TextEditingController? textController;
  final bool isCollapsed;
  const CommentInputBox({
    required this.onPressed,
    this.isSending = false,
    this.oldContent,
    required this.onTextChanged,
    this.textController,
    this.isCollapsed = true,
  });

  @override
  State<CommentInputBox> createState() => _CommentInputBoxState();
}

class _CommentInputBoxState extends State<CommentInputBox> {
  bool _hasInput = false;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.textController != null) {
      _controller = widget.textController!;
    } else {
      _controller = TextEditingController(text: widget.oldContent);
    }

    if (_controller.text.trim().isNotEmpty) {
      _hasInput = true;
      widget.onTextChanged(_controller.text);
    }
    _controller.addListener(() {
      // pass value back to showPickBottomSheet
      widget.onTextChanged(_controller.text);

      if (mounted) {
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
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (Get.find<UserService>().isMember.isFalse) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: Colors.white,
          child: ElevatedButton(
            onPressed: () {
              Get.to(
                () => const LoginPage(
                  fromComment: true,
                ),
                fullscreenDialog: true,
              );
            },
            style: ElevatedButton.styleFrom(
              primary: readrBlack87,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(
              widget.isCollapsed ? '建立帳號' : '註冊以參與討論',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        );
      }
      Color sendTextColor;
      Color textFieldTextColor = readrBlack;
      if (!_hasInput) {
        sendTextColor = Colors.white;
      } else if (widget.isSending) {
        sendTextColor = readrBlack20;
        textFieldTextColor = readrBlack20;
      } else {
        sendTextColor = Colors.blue;
      }

      return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        width: double.infinity,
        child: SafeArea(
          top: false,
          child: Stack(
            children: [
              ProfilePhotoWidget(Get.find<UserService>().currentUser, 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(width: 52),
                  Expanded(
                    child: TextField(
                      minLines: 1,
                      maxLines: 4,
                      readOnly: widget.isSending,
                      style: TextStyle(color: textFieldTextColor),
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '在這裡輸入留言...',
                        hintStyle: TextStyle(color: readrBlack30),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed:
                        (_hasInput && !widget.isSending) ? _sendComment : null,
                    child: Text(
                      '發佈',
                      style: TextStyle(
                        color: sendTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  void _sendComment() {
    widget.onPressed(_controller.text);
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
