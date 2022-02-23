import 'package:flutter/material.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/shared/ProfilePhotoWidget.dart';

class CommentInputBox extends StatefulWidget {
  final Member member;
  final void Function(String text) onPressed;
  final bool isSending;
  final String? oldContent;
  final ValueChanged<String> onTextChanged;
  final TextEditingController? textController;
  const CommentInputBox({
    required this.member,
    required this.onPressed,
    this.isSending = false,
    this.oldContent,
    required this.onTextChanged,
    this.textController,
  });

  @override
  _CommentInputBoxState createState() => _CommentInputBoxState();
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
    Color sendTextColor;
    Color textFieldTextColor = Colors.black;
    if (!_hasInput) {
      sendTextColor = Colors.white;
    } else if (widget.isSending) {
      sendTextColor = Colors.black26;
      textFieldTextColor = Colors.black26;
    } else {
      sendTextColor = Colors.blue;
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      width: double.infinity,
      child: SafeArea(
        top: false,
        child: Stack(
          children: [
            ProfilePhotoWidget(widget.member, 22),
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
                    ),
                  ),
                ),
                TextButton(
                  child: Text(
                    '發佈',
                    style: TextStyle(
                      color: sendTextColor,
                    ),
                  ),
                  onPressed:
                      (_hasInput && !widget.isSending) ? _sendComment : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendComment() {
    widget.onPressed(_controller.text);
  }
}
