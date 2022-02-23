import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsStoryItem.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/newsStoryService.dart';

part 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  NewsCubit() : super(NewsInitial());
  final MemberService _memberService = MemberService();
  final NewsStoryService _newsStoryService = NewsStoryService();

  fetchNewsData({
    required Member member,
    required String newsId,
    bool isNative = false,
  }) async {
    print('Fetch news data id=$newsId');
    emit(NewsLoading());
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        member = await _memberService.fetchMemberData();
      }
      NewsStoryItem newsStoryItem =
          await _newsStoryService.fetchNewsData(newsId, member);
      emit(NewsLoaded(newsStoryItem, member));
    } catch (e) {
      emit(NewsError(determineException(e)));
    }
  }
}
