part of 'bluetooth_bloc.dart';

@immutable
class BluetoothBlocState {}

class BluetoothConnected extends BluetoothBlocState {
  final BluetoothDevice device;
  final BluetoothConnection connection;
  BluetoothConnected({required this.device, required this.connection});
}

class BluetoothDisconnected extends BluetoothBlocState {}
