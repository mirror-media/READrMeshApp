import 'dart:async';

import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/pages/shared/ProfilePhotoWidget.dart';
import 'package:readr/pages/shared/timestamp.dart';

class CommentItem extends StatefulWidget {
  final Comment comment;
  final bool isLiked;
  final bool isExpanded;
  final bool isMyComment;
  final bool isFollowingComment;
  final bool isMyNewComment;
  final bool isSending;
  const CommentItem({
    required this.comment,
    this.isLiked = false,
    this.isExpanded = false,
    this.isMyComment = false,
    this.isFollowingComment = false,
    this.isMyNewComment = false,
    this.isSending = false,
  });

  @override
  _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _isExpanded = false;
  Color _backgroundColor = Colors.white;
  bool _isLiked = false;
  final FadeInController _fadeController = FadeInController();
  bool _isMyNewComment = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    _isMyNewComment = widget.isMyNewComment;
    if (widget.isFollowingComment) {
      _backgroundColor = const Color.fromRGBO(255, 245, 245, 1);
    } else if (widget.isSending) {
      _isExpanded = true;
      _backgroundColor = const Color.fromRGBO(255, 245, 245, 1);
    } else if (_isMyNewComment) {
      _backgroundColor = Colors.transparent;
      _isExpanded = true;
      Timer(const Duration(seconds: 5), () async {
        if (!_isDisposed) {
          _fadeController.fadeIn();
          await Future.delayed(const Duration(milliseconds: 255));
        }
        _isMyNewComment = false;
        _isExpanded = false;
      });
    }
    _isLiked = widget.isLiked;
  }

  @override
  void dispose() {
    super.dispose();
    _isDisposed = true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isMyNewComment) {
      return Container(
        color: const Color.fromRGBO(255, 245, 245, 1),
        child: Stack(
          children: [
            Positioned.fill(
              child: FadeIn(
                controller: _fadeController,
                child: Container(
                  color: Colors.white,
                ),
              ),
            ),
            _commentItemContent(),
          ],
        ),
      );
    }
    return _commentItemContent();
  }

  Widget _commentItemContent() {
    return Container(
      color: _backgroundColor,
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      height: _isExpanded ? null : 105,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfilePhotoWidget(
            widget.comment.member,
            22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _nameAndTime(),
                const SizedBox(height: 5),
                _content(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nameAndTime() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  widget.comment.member.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 2,
                height: 2,
                margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black26,
                ),
              ),
              if (widget.isSending)
                const Text(
                  '傳送中',
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              if (!widget.isSending) Timestamp(widget.comment.publishDate),
              if (widget.isMyComment) ...[
                Container(
                  width: 2,
                  height: 2,
                  margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black26,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    '編輯留言',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ],
          ),
        ),
        if (!widget.isSending)
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  widget.comment.likedCount.toString(),
                  style: const TextStyle(
                    color: Color.fromRGBO(0, 9, 40, 0.66),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 5),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_isLiked) {
                        widget.comment.likedCount--;
                      } else {
                        widget.comment.likedCount++;
                      }
                      _isLiked = !_isLiked;
                    });
                  },
                  iconSize: 18,
                  padding: const EdgeInsets.all(0),
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    _isLiked
                        ? Icons.favorite_outlined
                        : Icons.favorite_border_outlined,
                    color: _isLiked
                        ? Colors.red
                        : const Color.fromRGBO(0, 9, 40, 0.66),
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }

  Widget _content() {
    return GestureDetector(
      onTap: () {
        if (!_isExpanded) {
          setState(() {
            _isExpanded = true;
          });
        }
      },
      child: ExtendedText(
        widget.comment.content,
        maxLines: _isExpanded ? null : 2,
        style: const TextStyle(
          color: Color.fromRGBO(0, 9, 40, 0.66),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        joinZeroWidthSpace: true,
        overflowWidget: TextOverflowWidget(
          position: TextOverflowPosition.end,
          child: RichText(
            text: const TextSpan(
              text: '.... ',
              style: TextStyle(
                color: Color.fromRGBO(0, 9, 40, 0.66),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              children: [
                TextSpan(
                  text: '顯示更多',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
