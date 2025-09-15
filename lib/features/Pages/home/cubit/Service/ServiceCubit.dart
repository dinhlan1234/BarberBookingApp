import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/data/models/ServiceModel.dart';
import 'package:testrunflutter/features/Pages/home/cubit/Service/ServiceState.dart';

class ServiceCubit extends Cubit<ServiceState>{
  final String idShop;

  ServiceCubit({required this.idShop}): super(ServiceLoading()){
    _loadServices();
  }
  Future<void> _loadServices() async{
    emit(ServiceLoading());
    try{
      FireStoreDatabase dtb = FireStoreDatabase();
      List<ServiceModel> listServices = await dtb.getService(idShop);
      emit(ServiceLoaded(listServices: listServices));
    }catch(e){
      print(e);
      emit(ServiceError(message: 'Loi: $e'));
    }
  }

}