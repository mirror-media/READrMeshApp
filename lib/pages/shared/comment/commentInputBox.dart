import 'package:flutter/material.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/shared/ProfilePhotoWidget.dart';

class CommentInputBox extends StatefulWidget {
  final Member member;
  final void Function(String text) onPressed;
  final bool isSending;
  final String? oldContent;
  final ValueChanged<String> onTextChanged;
  const CommentInputBox({
    required this.member,
    required this.onPressed,
    this.isSending = false,
    this.oldContent,
    required this.onTextChanged,
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
  Widget build(BuildContext context) {
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
                      color: _hasInput ? Colors.blue : Colors.white,
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
    _controller.clear();
  }
}
