import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:meta/meta.dart';

part 'bluetooth_event.dart';
part 'bluetooth_state.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothBlocState> {
  BluetoothBloc() : super(BluetoothDisconnected()) {
    on<ConnectDevice>((event, emit) async {
      log("Connected to device : ${event.device.name}: ${event.device.address}");

      var connection =
          await BluetoothConnection.toAddress(event.device.address);

      emit(BluetoothConnected(device: event.device, connection: connection));
    });
  }
}
