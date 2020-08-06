import 'dart:convert';
// async reikalingas, kad galetume nustatyti timeri, kada user'is butu automatiskai atjungtas nuo app'o
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../modal/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

//  reikalinga zinoti koki screen'a rodyti
// jein token'as neExpirines ir egzistuoja reiskia zmogus authentikuotas.
  bool get isAuth {
    return token != null;
    //  mintis tokia, jei tokenas nera lygus 0, reiskia mes authentikuoti.
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyA1OvNeDb2qWoq0NOjxx1UssA5A-g1Ab5o';

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

//  cia gaunam response data
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      //  expire date, gauname int skaiciu.. todel mum reikia paimti ta skaiciu ir konvertuoti i data
      // expiryDta skaiciuojama.. dabar + expiredIn token'o laikas secundem
      _expiryDate = DateTime.now().add(Duration(
        seconds: int.parse(
          responseData['expiresIn'],
        ),
      ));
      _autoLogout();
      notifyListeners();
      // get access and store it. sharedPref issaugo i tel memory
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String()
      });
      prefs.setString('userData', userData);
    } catch (error) {
      // throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'singupNewUser');
    //  jei butu be zodelio -return- authenticate nebutu laukes kol issius i firebase
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'verifyPassword');
  }

// AUTO LOGIN, panaudojam MAIN.e
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryData = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryData.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryData;
    notifyListeners();
    _autoLogout();
    return true;
  }

  //  LOGOUT'as

  Future<void> logOut() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    // reikia pratrinti login duomenys issaugotus
    final prefs = await SharedPreferences.getInstance();
    //  clear istrina visa informacija is mobile memorry
    //  jei man reikia kad kazkas pasiliktu, turiu naudoti prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogout() {
//  jeigu jau sukasi tas timer'is sitam user'iu -tada skip.
    if (_authTimer != null) {
      _authTimer.toString();
    }

    var timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logOut);
  }
}
