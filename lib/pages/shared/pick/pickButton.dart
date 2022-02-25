import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/shared/pick/pickBottomSheet.dart';
import 'package:readr/pages/shared/pick/pickToast.dart';

class PickButton extends StatefulWidget {
  final PickableItem item;
  final bool expanded;
  final double textSize;
  final void Function()? afterPicked;
  final void Function()? afterRemovePick;
  final void Function()? whenPickFailed;
  final void Function()? whenRemoveFailed;
  const PickButton(
    this.item, {
    this.expanded = false,
    this.textSize = 14,
    this.afterPicked,
    this.afterRemovePick,
    this.whenPickFailed,
    this.whenRemoveFailed,
  });

  @override
  _PickButtonState createState() => _PickButtonState();
}

class _PickButtonState extends State<PickButton> {
  late bool _isPicked;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isPicked = widget.item.pickId != null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.expanded) {
      return SizedBox(
        width: double.maxFinite,
        child: _buildButton(context),
      );
    }
    return _buildButton(context);
  }

  Widget _buildButton(BuildContext context) {
    return OutlinedButton(
      onPressed: _isLoading
          ? null
          : () async {
              // check whether is login
              if (UserHelper.instance.isMember) {
                if (!_isPicked) {
                  var result = await PickBottomSheet.showPickBottomSheet(
                    context: context,
                  );

                  if ((result is bool && result) || (result is String)) {
                    // refresh UI first
                    setState(() {
                      _isPicked = true;
                      // freeze onPressed when waiting for response
                      _isLoading = true;
                      if (widget.afterPicked != null) {
                        widget.afterPicked!();
                      }
                    });

                    String? pickId;
                    if (result is bool && result) {
                      pickId = await widget.item.createPick();
                    } else if (result is String) {
                      await widget.item
                          .createPickAndComment(result)
                          .then((value) => pickId = value?['pickId']);
                    }

                    // If pickId is null, mean failed
                    PickToast.showPickToast(context, pickId != null, true);
                    if (pickId == null) {
                      setState(() {
                        if (widget.whenPickFailed != null) {
                          widget.whenPickFailed!();
                        }
                        _isPicked = false;
                      });
                    }
                    // Let onPressed function can be called
                    setState(() {
                      _isLoading = false;
                    });
                  }
                } else {
                  // refresh UI first
                  setState(() {
                    _isPicked = false;
                    // freeze onPressed when waiting for response
                    _isLoading = true;
                    if (widget.afterRemovePick != null) {
                      widget.afterRemovePick!();
                    }
                  });

                  // send request to api
                  bool isSuccess = await widget.item.deletePick();

                  // show toast by result
                  PickToast.showPickToast(context, isSuccess, false);

                  // when failed, recovery UI and news' myPickId
                  if (!isSuccess) {
                    setState(() {
                      if (widget.whenRemoveFailed != null) {
                        widget.whenRemoveFailed!();
                      }
                      _isPicked = !_isPicked;
                    });
                  }
                  // Let onPressed function can be called
                  setState(() {
                    _isLoading = false;
                  });
                }
              } else {
                AutoRouter.of(context).push(const LoginRoute());
              }
            },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.black87, width: 1),
        backgroundColor: _isPicked ? Colors.black87 : Colors.white,
        padding: const EdgeInsets.fromLTRB(11, 3, 12, 4),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
              child: Icon(
                _isPicked ? Icons.done_outlined : Icons.add_outlined,
                size: widget.textSize + 4,
                color: _isPicked ? Colors.white : Colors.black87,
              ),
            ),
            TextSpan(
              text: _isPicked ? '已精選' : '精選',
              style: TextStyle(
                fontSize: widget.textSize,
                height: 1.9,
                color: _isPicked ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
