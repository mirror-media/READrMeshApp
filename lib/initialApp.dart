import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/pickButton/pickButton_cubit.dart';
import 'package:readr/blocs/readr/categories/bloc.dart';
import 'package:readr/blocs/config/bloc.dart';
import 'package:readr/helpers/dynamicLinkHelper.dart';
import 'package:readr/pages/rootPage.dart';
import 'package:readr/pages/shared/pick/pickToast.dart';
import 'package:readr/services/categoryService.dart';
import 'package:readr/services/configService.dart';

class InitialApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DynamicLinkHelper().initDynamicLinks(context);
    return BlocListener<PickButtonCubit, PickButtonState>(
      listener: (context, state) {
        if (state is PickButtonUpdateSuccess) {
          PickToast.showPickToast(context, true, state.isPicked);
        }

        if (state is PickButtonUpdateFailed) {
          PickToast.showPickToast(context, false, state.originIsPicked);
        }
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ConfigBloc(configRepos: ConfigServices()),
          ),
          BlocProvider(
            create: (context) =>
                CategoriesBloc(categoryRepos: CategoryServices()),
          ),
        ],
        child: RootPage(),
      ),
    );
  }
}
