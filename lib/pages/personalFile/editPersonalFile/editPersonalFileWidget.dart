import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/blocs/editPersonalFile/editPersonalFile_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/errorPage.dart';

class EditPersonalFileWidget extends StatefulWidget {
  @override
  _EditPersonalFileWidgetState createState() => _EditPersonalFileWidgetState();
}

class _EditPersonalFileWidgetState extends State<EditPersonalFileWidget> {
  bool _isEdited = false;
  bool _isAttached = false;
  late final TextEditingController _nicknameController;
  late final TextEditingController _customIdController;
  late final TextEditingController _introController;
  final FocusNode _nicknameFocusNode = FocusNode();
  final FocusNode _customIdFocusNode = FocusNode();
  final FocusNode _introFocusNode = FocusNode();
  bool _isFocusNickname = false;
  bool _isFocusCustomId = false;
  bool _isSaving = false;
  bool _customIdError = false;
  bool _nicknameError = false;
  final _formKey = GlobalKey<FormState>();
  bool _alreadyShowError = false;

  @override
  void initState() {
    super.initState();
    _loadMemberData();
    _nicknameFocusNode.addListener(() {
      if (_nicknameFocusNode.hasFocus) {
        setState(() {
          _isFocusNickname = true;
          _isFocusCustomId = false;
        });
      }
    });
    _customIdFocusNode.addListener(() {
      if (_customIdFocusNode.hasFocus) {
        setState(() {
          _isFocusNickname = false;
          _isFocusCustomId = true;
        });
      }
    });
    _introFocusNode.addListener(() {
      if (_introFocusNode.hasFocus) {
        setState(() {
          _isFocusNickname = false;
          _isFocusCustomId = false;
        });
      }
    });
  }

  _loadMemberData() {
    context.read<EditPersonalFileCubit>().loadPersonalFile();
  }

  _saveMemberData() {
    context.read<EditPersonalFileCubit>().savePersonalFile(Member(
          memberId: UserHelper.instance.currentUser.memberId,
          nickname: _nicknameController.text,
          customId: _customIdController.text,
          avatar: UserHelper.instance.currentUser.avatar,
          intro: _introController.text,
          followingPublisher: [],
          following: [],
        ));
  }

  @override
  void dispose() {
    super.dispose();
    if (_isAttached) {
      _nicknameController.dispose();
      _customIdController.dispose();
      _introController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditPersonalFileCubit, EditPersonalFileState>(
      listener: (context, state) {
        if (state is PersonalFileSaved) {
          context.popRoute(true);
        }

        if (state is SavePersonalFileFailed) {
          print('SavePersonalFileFailed');
          Fluttertoast.showToast(
            msg: "儲存失敗",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      },
      builder: (context, state) {
        if (state is EditPersonalFileError) {
          final error = state.error;
          print('EditPersonalFileError: ${error.message}');

          return ErrorPage(
            error: error,
            onPressed: () => _loadMemberData(),
            hideAppbar: true,
          );
        }

        if (state is PersonalFileSaving) {
          _alreadyShowError = false;
          _isSaving = true;
          return _buildContent(context);
        }

        if (state is SavePersonalFileFailed) {
          _isSaving = false;
          return _buildContent(context);
        }

        if (state is PersonalFileIdError) {
          _isSaving = false;
          if (!_alreadyShowError) {
            _customIdError = true;
            _formKey.currentState!.validate();
            _alreadyShowError = true;
          }
          return _buildContent(context);
        }

        if (state is PersonalFileNicknameError) {
          _isSaving = false;
          if (!_alreadyShowError) {
            _nicknameError = true;
            _formKey.currentState!.validate();
            _alreadyShowError = true;
          }
          return _buildContent(context);
        }

        if (state is EditPersonalFileLoaded) {
          if (!_isAttached) {
            _nicknameController = TextEditingController(
                text: UserHelper.instance.currentUser.nickname);
            _customIdController = TextEditingController(
                text: UserHelper.instance.currentUser.customId);
            _introController = TextEditingController(
                text: UserHelper.instance.currentUser.intro);
            _isAttached = true;
          }

          return _buildContent(context);
        }

        return SafeArea(
          child: Column(
            children: [
              _buildBar(),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: GestureDetector(
          onTap: () => context.popRoute(false),
          child: Platform.isIOS
              ? const Text(
                  '取消',
                  style: TextStyle(
                    color: readrBlack50,
                    fontSize: 18,
                  ),
                )
              : const Icon(
                  Icons.close,
                  color: readrBlack,
                ),
        ),
      ),
      centerTitle: Platform.isIOS,
      title: const Text('編輯個人檔案',
          style: TextStyle(
            fontSize: 18,
            color: readrBlack,
            fontWeight: FontWeight.w400,
          )),
      actions: [
        if (_isEdited)
          TextButton(
            onPressed: _isSaving ? null : () => _saveMemberData(),
            child: const Text(
              '儲存',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildBar(),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: _buildForm(context),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        autovalidateMode: AutovalidateMode.always,
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              focusNode: _nicknameFocusNode,
              controller: _nicknameController,
              autocorrect: false,
              keyboardType: TextInputType.name,
              maxLength: 20,
              onChanged: (value) {
                _nicknameError = false;
                checkIsEdited();
              },
              style: const TextStyle(
                color: readrBlack87,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                labelText: '姓名',
                labelStyle: const TextStyle(
                  color: readrBlack50,
                  fontSize: 18,
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: readrBlack87,
                  ),
                ),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white10,
                  ),
                ),
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                suffix: (_nicknameController.text.isEmpty || !_isFocusNickname)
                    ? null
                    : GestureDetector(
                        onTap: () {
                          _nicknameController.clear();
                          setState(() {});
                        },
                        child: const Icon(
                          Icons.cancel,
                          color: readrBlack87,
                          size: 16,
                        ),
                      ),
              ),
              validator: (value) {
                if (_nicknameError) return '這個名稱目前無法使用，請使用其他名稱。';
                return value!.trim().isNotEmpty ? null : "姓名不能空白";
              },
            ),
            const SizedBox(
              height: 24,
            ),
            TextFormField(
              controller: _customIdController,
              focusNode: _customIdFocusNode,
              keyboardType: TextInputType.name,
              autocorrect: false,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[\u4E00-\u9FFF]')),
                FilteringTextInputFormatter.allow(RegExp(r'[_.\w]'))
              ],
              onChanged: (value) {
                _customIdError = false;
                checkIsEdited();
              },
              style: const TextStyle(
                color: readrBlack87,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                labelText: 'ID',
                labelStyle: const TextStyle(
                  color: readrBlack50,
                  fontSize: 18,
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: readrBlack87,
                  ),
                ),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white10,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                suffix: (_customIdController.text.isEmpty || !_isFocusCustomId)
                    ? null
                    : GestureDetector(
                        onTap: () {
                          _customIdController.clear();
                          setState(() {});
                        },
                        child: const Icon(
                          Icons.cancel,
                          color: readrBlack87,
                          size: 16,
                        ),
                      ),
              ),
              validator: (value) {
                if (_customIdError) return '這個 ID 目前無法使用，請使用其他 ID。';
                return value!.trim().isNotEmpty ? null : "ID不能空白";
              },
            ),
            const SizedBox(
              height: 24,
            ),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '簡介',
                    style: TextStyle(
                      color: readrBlack50,
                      fontSize: 14,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _introController.text.length.toString() + '/250字',
                    style: const TextStyle(
                      color: readrBlack50,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: TextFormField(
                controller: _introController,
                focusNode: _introFocusNode,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                maxLength: 250,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                onChanged: (value) {
                  checkIsEdited();
                },
                style: const TextStyle(
                  color: readrBlack87,
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  hintText: '向大家介紹一下自己吧...',
                  hintStyle: TextStyle(
                    color: readrBlack30,
                    fontSize: 16,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: readrBlack87,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white10,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(12),
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  void checkIsEdited() {
    if (_nicknameController.text.isEmpty || _customIdController.text.isEmpty) {
      setState(() {
        _isEdited = false;
      });
    } else if (_nicknameController.text !=
        UserHelper.instance.currentUser.nickname) {
      setState(() {
        _isEdited = true;
      });
    } else if (_customIdController.text !=
        UserHelper.instance.currentUser.customId) {
      setState(() {
        _isEdited = true;
      });
    } else if (_introController.text != UserHelper.instance.currentUser.intro) {
      setState(() {
        _isEdited = true;
      });
    } else {
      setState(() {
        _isEdited = false;
      });
    }
  }
}
