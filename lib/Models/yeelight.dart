import 'dart:io';
import 'package:equatable/equatable.dart';

class Yeelight extends Equatable {
  String _name;
  InternetAddress _ip;
  bool _status;

  Yeelight(
      {required String name, required InternetAddress ip, required bool status})
      : this._name = name,
        this._ip = ip,
        this._status = status;

  String get name {
    return _name;
  }

  InternetAddress get ip {
    return _ip;
  }

  bool get status {
    return _status;
  }

  set name(String name) {
    this._name = name;
  }

  set ip(InternetAddress ip) {
    this._ip = ip;
  }

  set status(bool status) {
    this._status = status;
  }

  @override
  List<Object?> get props => [_name, _ip, _status];
}
