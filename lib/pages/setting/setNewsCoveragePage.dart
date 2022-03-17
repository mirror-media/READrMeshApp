import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetNewsCoveragePage extends StatefulWidget {
  final int duration;
  const SetNewsCoveragePage(this.duration, {Key? key}) : super(key: key);

  @override
  State<SetNewsCoveragePage> createState() => _SetNewsCoveragePageState();
}

class _SetNewsCoveragePageState extends State<SetNewsCoveragePage> {
  int _checkIndex = 0;

  @override
  void initState() {
    super.initState();

    if (widget.duration == 72) {
      _checkIndex = 1;
    } else if (widget.duration == 168) {
      _checkIndex = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          '顯示新聞範圍',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: homeScreenBackgroundColor,
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(0),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => _buildItem(context, index),
          separatorBuilder: (context, index) => const Divider(
            color: Colors.black12,
            height: 0.5,
            thickness: 0.5,
            indent: 20,
            endIndent: 20,
          ),
          itemCount: 3,
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    String title = '24小時內';
    if (index == 1) {
      title = '3天內';
    } else if (index == 2) {
      title = '1週內';
    }
    return GestureDetector(
      onTap: () async {
        setState(() {
          _checkIndex = index;
        });
        await _setCoverageTime();
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: readrBlack87,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
            if (_checkIndex == index)
              const Icon(
                Icons.check_outlined,
                color: Colors.blue,
                size: 16,
              )
          ],
        ),
      ),
    );
  }

  _setCoverageTime() async {
    final prefs = await SharedPreferences.getInstance();
    int duration = 24;
    if (_checkIndex == 1) {
      duration = 72;
    } else if (_checkIndex == 2) {
      duration = 168;
    }
    await prefs.setInt('newsCoverage', duration);
  }
}
