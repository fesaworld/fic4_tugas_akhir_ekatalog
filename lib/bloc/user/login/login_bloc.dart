import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/datasources/auth_datasources.dart';
import '../../../data/localsources/auth_local_storage.dart';
import '../../../data/models/request/login_model.dart';
import '../../../data/models/response/login_response_model.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthDatasource authDatasource;
  LoginBloc(
    this.authDatasource,
  ) : super(LoginInitial()) {
    on<DoLoginEvent>((event, emit) async {
      emit(LoginLoading());
      final result = await authDatasource.login(event.loginModel);

      result.fold(
        (error) {
          emit(LoginError(message: error));
        },
        (data) {
          AuthLocalStorage().saveToken(data.accessToken);
          emit(LoginLoaded(loginResponseModel: data));
        },
      );
    });
  }
}
