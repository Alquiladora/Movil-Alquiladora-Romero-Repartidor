import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/ape_service_home.dart';
import './home_event.dart';
import './home_state.dart';

class HomeBloc extends Bloc<HomeEvent,HomeState>{
  final HomeService homeservice;

  HomeBloc({required this.homeservice}): super (HomeInicial()){
    on<LoadHomeData>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(LoadHomeData event, Emitter <HomeState> emit) async{
    emit(HomeLoading());

    try{
      final result = await homeservice.getHome();
      if(result['success']){
        final data= result['data'];
        emit(HomeSuccess(data));
      }else{
        final bool isAuthError = result['isAuthError'] == true;
    if (isAuthError) {
        emit(HomeError('AUTH_REQUIRED_401')); 
    } else {
        emit(HomeError(result['message'] ?? 'Error desconocido.') );
      
    }
    }
    }catch (e) {
      emit(HomeError('Error de conexión: ${e.toString()}'));
    }
  }
}