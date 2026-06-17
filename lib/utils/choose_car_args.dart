import 'choose_car_bottom_sheet/models/choose_car_model.dart';

class ChooseCarArgs {
  final String serviceName;
  final List<Car>? car;
  final int? index;

  ChooseCarArgs({this.index, required this.serviceName, this.car});
}
