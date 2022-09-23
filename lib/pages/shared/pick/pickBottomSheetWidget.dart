import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/themes.dart';

import 'package:readr/pages/shared/profilePhotoWidget.dart';

class PickBottomSheetWidget extends StatefulWidget {
  final ValueChanged<String> onTextChanged;
  final String? oldContent;

  const PickBottomSheetWidget({
    required this.onTextChanged,
    this.oldContent,
  });

  @override
  State<PickBottomSheetWidget> createState() => _PickBottomSheetWidgetState();
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
      color: Theme.of(context).backgroundColor,
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
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
            TextField(
              minLines: 1,
              maxLines: 6,
              controller: _controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'pickCommentHint'.tr,
                hintStyle: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(fontSize: 16),
              ),
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontSize: 16),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: Text(
                  _hasInput ? 'publish'.tr : 'pickDirectly'.tr,
                  style: TextStyle(
                    color:
                        Theme.of(context).extension<CustomColors>()!.systemBlue,
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
