import 'dart:io';
import 'package:equatable/equatable.dart';

class Yeelight extends Equatable {
  String _name;
  InternetAddress _ip;
  bool _status;
  int _bright;

  Yeelight(
      {required String name,
      required InternetAddress ip,
      required bool status,
      required int bright})
      : this._name = name,
        this._ip = ip,
        this._status = status,
        this._bright = bright;

  String get name {
    return _name;
  }

  InternetAddress get ip {
    return _ip;
  }

  bool get status {
    return _status;
  }

  int get bright {
    return _bright;
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

  set bright(int bright) {
    this._bright = bright;
  }

  @override
  List<Object?> get props => [_name, _ip];
}
