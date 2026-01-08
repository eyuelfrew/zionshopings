import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/address_model.dart';

class AddressController with ChangeNotifier {
  List<Address> _addresses = [];
  static const String _storageKey = 'saved_addresses';

  List<Address> get addresses => _addresses;
  
  Address? get defaultAddress {
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  AddressController() {
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      _addresses = jsonList.map((j) => Address.fromJson(j)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_addresses.map((a) => a.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  Future<void> addAddress(Address address) async {
    // If it's the first address or marked as default, unset others as default
    if (_addresses.isEmpty || address.isDefault) {
      _addresses = _addresses.map((a) => a.copyWith(isDefault: false)).toList();
      address = address.copyWith(isDefault: true);
    }
    
    _addresses.add(address);
    await _saveAddresses();
    notifyListeners();
  }

  Future<void> updateAddress(Address updatedAddress) async {
    final index = _addresses.indexWhere((a) => a.id == updatedAddress.id);
    if (index != -1) {
      if (updatedAddress.isDefault) {
        _addresses = _addresses.map((a) => a.copyWith(isDefault: false)).toList();
      }
      _addresses[index] = updatedAddress;
      
      // Ensure at least one default if list not empty
      if (_addresses.where((a) => a.isDefault).isEmpty && _addresses.isNotEmpty) {
        _addresses[0] = _addresses[0].copyWith(isDefault: true);
      }

      await _saveAddresses();
      notifyListeners();
    }
  }

  Future<void> removeAddress(String id) async {
    final wasDefault = _addresses.any((a) => a.id == id && a.isDefault);
    _addresses.removeWhere((a) => a.id == id);
    
    if (wasDefault && _addresses.isNotEmpty) {
      _addresses[0] = _addresses[0].copyWith(isDefault: true);
    }
    
    await _saveAddresses();
    notifyListeners();
  }

  Future<void> setDefault(String id) async {
    _addresses = _addresses.map((a) => a.copyWith(isDefault: a.id == id)).toList();
    await _saveAddresses();
    notifyListeners();
  }
}
