import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:readr/helpers/apiException.dart';
import 'package:readr/helpers/exceptions.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsStoryItem.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/newsStoryService.dart';

part 'news_event.dart';
part 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final MemberService _memberService = MemberService();
  final NewsStoryService _newsStoryService = NewsStoryService();

  NewsBloc() : super(NewsInitial()) {
    on<NewsEvent>((event, emit) async {
      print(event.toString());
      try {
        if (event is FetchNews) {
          emit(NewsLoading());
          Member member;
          if (FirebaseAuth.instance.currentUser != null) {
            member = await _memberService.fetchMemberData();
          } else {
            member = event.member;
          }
          NewsStoryItem newsStoryItem =
              await _newsStoryService.fetchNewsData(event.newsId, member);
          emit(NewsLoaded(newsStoryItem, member));
        }
      } catch (e) {
        if (e is SocketException) {
          emit(NewsError(NoInternetException('No Internet')));
        } else if (e is HttpException) {
          emit(NewsError(NoServiceFoundException('No Service Found')));
        } else if (e is FormatException) {
          emit(NewsError(InvalidFormatException('Invalid Response format')));
        } else if (e is FetchDataException) {
          emit(NewsError(NoInternetException('Error During Communication')));
        } else if (e is BadRequestException ||
            e is UnauthorisedException ||
            e is InvalidInputException) {
          emit(NewsError(Error400Exception('Unauthorised')));
        } else if (e is InternalServerErrorException) {
          emit(NewsError(Error500Exception('Internal Server Error')));
        } else {
          emit(NewsError(UnknownException(e.toString())));
        }
      }
    });
  }
}
