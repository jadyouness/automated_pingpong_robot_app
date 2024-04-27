part of 'bluetooth_bloc.dart';

@immutable
sealed class BluetoothEvent {}

class ConnectDevice extends BluetoothEvent {
  final BluetoothDevice device;
  ConnectDevice({required this.device});
}
