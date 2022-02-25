import 'package:flutter/material.dart';
import 'package:readr/models/followableItem.dart';
import 'package:easy_debounce/easy_debounce.dart';

class FollowButton extends StatefulWidget {
  final FollowableItem item;
  final bool expanded;
  final double textSize;
  final void Function()? onTap;
  final void Function()? whenFailed;
  const FollowButton(
    this.item, {
    this.expanded = false,
    this.textSize = 14,
    this.onTap,
    this.whenFailed,
  });

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.item.isFollowed;
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
      onPressed: () async {
        setState(() {
          _isFollowing = !_isFollowing;
        });
        if (widget.onTap != null) {
          widget.onTap!();
        }
        EasyDebounce.debounce(
            widget.item.id, const Duration(seconds: 2), () => _updateFollow());
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.black87, width: 1),
        backgroundColor: _isFollowing ? Colors.black87 : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      ),
      child: Text(
        _isFollowing ? '追蹤中' : '追蹤',
        maxLines: 1,
        style: TextStyle(
          fontSize: widget.textSize,
          color: _isFollowing ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Future<void> _updateFollow() async {
    bool isSuccess = _isFollowing
        ? await widget.item.addFollow()
        : await widget.item.removeFollow();

    if (!isSuccess && mounted) {
      setState(() {
        _isFollowing = !_isFollowing;
      });
      if (widget.whenFailed != null) {
        widget.whenFailed!();
      }
    }
  }
}
