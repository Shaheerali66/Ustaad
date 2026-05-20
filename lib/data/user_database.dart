import 'dart:convert';
import 'document_database.dart';
import 'platform_storage.dart';
import 'package:http/http.dart' as http;

class UserDatabase {
  static List<Map<String, dynamic>> _users = [];
  static List<Map<String, dynamic>> get users => _users;
  static Map<String, dynamic>? _currentUser;
  static bool _isFirstLoginAfterSignup = false;

  static Map<String, dynamic>? _currentTechnician;

  static String? _temporaryLocation;
  static String? _temporaryCity;

  static String? get temporaryLocation => _temporaryLocation;
  static String? get temporaryCity => _temporaryCity;

  static set temporaryLocation(String? val) => _temporaryLocation = val;
  static set temporaryCity(String? val) => _temporaryCity = val;

  static void clearTemporaryLocation() {
    _temporaryLocation = null;
    _temporaryCity = null;
  }

  static String get activeLocation {
    if (_temporaryLocation != null && _temporaryLocation!.isNotEmpty) {
      return _temporaryLocation!;
    }
    if (_currentUser != null) {
      return _currentUser!['address']?.toString() ?? 'G-13, Islamabad';
    }
    return 'G-13, Islamabad';
  }

  static String get activeCity {
    if (_temporaryCity != null && _temporaryCity!.isNotEmpty) {
      return _temporaryCity!;
    }
    if (_currentUser != null) {
      return _currentUser!['city']?.toString() ?? 'Islamabad';
    }
    return 'Islamabad';
  }

  static const String _usersKey = 'ustaad_registered_users_v1';
  static const String _currentUserKey = 'ustaad_current_user_v1';
  static const String _firstLoginKey = 'ustaad_first_login_flag_v1';
  static const String _currentTechKey = 'ustaad_current_tech_v1';
  static const String _usersCloudUrl = 'https://jsonbin-zeta.vercel.app/api/bins/VRHuwcv2Jv';

  static Future<bool> syncUsersToCloud() async {
    try {
      final response = await http.put(
        Uri.parse(_usersCloudUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_users),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> syncUsersFromCloud() async {
    try {
      final response = await http.get(Uri.parse(_usersCloudUrl));
      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(response.body);
        if (decoded.isNotEmpty) {
          _users = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          _ensureDemoCustomer();
          _saveUsers();
          return true;
        } else {
          // Cloud empty? Upload defaults
          if (_users.isEmpty) {
            _users = [
              {
                'fullName': 'Ahmed Ali',
                'email': 'ahmed@gmail.com',
                'phone': '0300-1234567',
                'address': 'House 12, Street 4, Sector G-13',
                'city': 'Islamabad',
                'password': 'Password123',
                'role': 'customer',
              }
            ];
          }
          _ensureDemoCustomer();
          _saveUsers();
          await syncUsersToCloud();
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static void _ensureDemoCustomer() {
    final demoEmail = 'admin123@gmail.com';
    final index = _users.indexWhere((u) => u['email']?.toString().toLowerCase().trim() == demoEmail);
    final demoAccount = {
      'fullName': 'Demo Customer',
      'email': demoEmail,
      'phone': '03001234567',
      'address': 'House 1, Street 1, F-7',
      'city': 'Islamabad',
      'password': 'Admin12345',
      'role': 'customer',
    };
    if (index == -1) {
      _users.add(demoAccount);
      _saveUsers();
    } else {
      final existing = _users[index];
      if (existing['fullName'] != 'Demo Customer' ||
          existing['password'] != 'Admin12345' ||
          existing['phone'] != '03001234567' ||
          existing['address'] != 'House 1, Street 1, F-7' ||
          existing['city'] != 'Islamabad') {
        _users[index] = demoAccount;
        _saveUsers();
      }
    }
  }

  static void init() {
    try {
      // Load users
      final usersData = PlatformStorage.getString(_usersKey);
      if (usersData != null && usersData.trim().isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(usersData);
        _users = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        // Seed default user
        _users = [
          {
            'fullName': 'Ahmed Ali',
            'email': 'ahmed@gmail.com',
            'phone': '0300-1234567',
            'address': 'House 12, Street 4, Sector G-13',
            'city': 'Islamabad',
            'password': 'Password123',
            'role': 'customer',
          }
        ];
        _saveUsers();
      }

      // Load current logged-in user
      final currentUserData = PlatformStorage.getString(_currentUserKey);
      if (currentUserData != null && currentUserData.trim().isNotEmpty) {
        _currentUser = jsonDecode(currentUserData);
      }

      // Load current logged-in technician
      final currentTechData = PlatformStorage.getString(_currentTechKey);
      if (currentTechData != null && currentTechData.trim().isNotEmpty) {
        _currentTechnician = jsonDecode(currentTechData);
      }

      // Load first login flag
      final firstLoginData = PlatformStorage.getString(_firstLoginKey);
      if (firstLoginData != null) {
        _isFirstLoginAfterSignup = firstLoginData == 'true';
      }
    } catch (_) {
      // Stub fallback
      _users = [
        {
          'fullName': 'Ahmed Ali',
          'email': 'ahmed@gmail.com',
          'phone': '0300-1234567',
          'address': 'House 12, Street 4, Sector G-13',
          'city': 'Islamabad',
          'password': 'Password123',
          'role': 'customer',
        }
      ];
    }
    _ensureDemoCustomer();
    syncUsersFromCloud();
    syncUsersToCloud();
  }

  static bool get isAuthenticated => _currentUser != null;

  static Map<String, dynamic>? get currentUser => _currentUser;

  static bool get isTechAuthenticated => _currentTechnician != null;

  static Map<String, dynamic>? get currentTechnician => _currentTechnician;

  static void _saveCurrentTechnician() {
    try {
      if (_currentTechnician != null) {
        PlatformStorage.setString(_currentTechKey, jsonEncode(_currentTechnician));
      } else {
        PlatformStorage.remove(_currentTechKey);
      }
    } catch (_) {}
  }

  static void techLogin(Map<String, dynamic> tech) {
    _currentTechnician = tech;
    _saveCurrentTechnician();
  }

  static void techLogout() {
    _currentTechnician = null;
    _saveCurrentTechnician();
  }

  static bool get isFirstLogin => _isFirstLoginAfterSignup;

  static void clearFirstLoginFlag() {
    _isFirstLoginAfterSignup = false;
    try {
      PlatformStorage.setString(_firstLoginKey, 'false');
    } catch (_) {}
  }

  static void _saveUsers() {
    try {
      PlatformStorage.setString(_usersKey, jsonEncode(_users));
    } catch (_) {}
  }

  static void _saveCurrentUser() {
    try {
      if (_currentUser != null) {
        PlatformStorage.setString(_currentUserKey, jsonEncode(_currentUser));
      } else {
        PlatformStorage.remove(_currentUserKey);
      }
    } catch (_) {}
  }

  static bool login(String email, String password) {
    init(); // Ensure loaded
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();
    final index = _users.indexWhere(
      (u) => u['email']?.toString().toLowerCase().trim() == cleanEmail && u['password']?.toString().trim() == cleanPassword
    );
    if (index != -1) {
      _currentUser = Map<String, dynamic>.from(_users[index]);
      _isFirstLoginAfterSignup = false;
      try {
        PlatformStorage.setString(_firstLoginKey, 'false');
      } catch (_) {}
      _saveCurrentUser();
      return true;
    }
    return false;
  }

  static Map<String, dynamic> _sanitizeUserData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};
    data.forEach((key, value) {
      if (value is String || value is num || value is bool || value == null) {
        sanitized[key] = value;
      } else if (value is Map) {
        sanitized[key] = _sanitizeUserData(Map<String, dynamic>.from(value));
      } else if (value is List) {
        sanitized[key] = value.map((e) => e is Map ? _sanitizeUserData(Map<String, dynamic>.from(e)) : e).toList();
      } else {
        if (value.runtimeType.toString().contains('Timestamp') || value.runtimeType.toString().contains('FieldValue')) {
          sanitized[key] = value.toString();
        }
      }
    });
    return sanitized;
  }

  static void forceLogin(Map<String, dynamic> userData) {
    init(); // Ensure loaded
    _currentUser = _sanitizeUserData(userData);
    _isFirstLoginAfterSignup = false;
    try {
      PlatformStorage.setString(_firstLoginKey, 'false');
    } catch (_) {}
    _saveCurrentUser();
  }

  static Future<bool> signup(Map<String, dynamic> userData) async {
    try {
      await syncUsersFromCloud();
      await DocumentDatabase.syncFromCloud();
    } catch (_) {}
    
    final email = userData['email']?.toString().toLowerCase().trim() ?? '';
    
    // Check workers (prevent worker email reuse for customer)
    final hasWorker = DocumentDatabase.onboardedTechnicians.any((t) => t['email']?.toString().toLowerCase().trim() == email);
    if (hasWorker) {
      return false; // Cannot register as customer if already a worker
    }

    final sanitizedData = _sanitizeUserData(userData);
    final newUserData = Map<String, dynamic>.from(sanitizedData);
    newUserData['email'] = email;
    newUserData['password'] = newUserData['password']?.toString().trim();
    newUserData['role'] = 'customer';

    // Update existing customer in mock list if they exist, otherwise add them
    final existingIndex = _users.indexWhere((u) => u['email']?.toString().toLowerCase().trim() == email);
    if (existingIndex != -1) {
      _users[existingIndex] = newUserData;
    } else {
      _users.add(newUserData);
    }
    
    _saveUsers();
    try {
      await syncUsersToCloud();
    } catch (_) {}

    // Automatically log in
    _currentUser = newUserData;
    _isFirstLoginAfterSignup = true;
    try {
      PlatformStorage.setString(_firstLoginKey, 'true');
    } catch (_) {}
    _saveCurrentUser();
    return true;
  }

  static void logout() {
    _currentUser = null;
    _isFirstLoginAfterSignup = false;
    _saveCurrentUser();
    try {
      PlatformStorage.remove(_currentUserKey);
      PlatformStorage.remove(_firstLoginKey);
    } catch (_) {}
  }

  static Future<void> updateProfile(Map<String, dynamic> updatedData) async {
    if (_currentUser == null) return;
    
    await syncUsersFromCloud();

    // Update local currentUser
    updatedData.forEach((key, value) {
      if (key == 'email') {
        _currentUser![key] = value?.toString().toLowerCase().trim();
      } else if (key == 'password') {
        _currentUser![key] = value?.toString().trim();
      } else {
        _currentUser![key] = value;
      }
    });
    _saveCurrentUser();

    // Update in users list
    final email = _currentUser!['email']?.toString().toLowerCase().trim();
    final index = _users.indexWhere((u) => u['email']?.toString().toLowerCase().trim() == email);
    if (index != -1) {
      updatedData.forEach((key, value) {
        if (key == 'email') {
          _users[index][key] = value?.toString().toLowerCase().trim();
        } else if (key == 'password') {
          _users[index][key] = value?.toString().trim();
        } else {
          _users[index][key] = value;
        }
      });
      _saveUsers();
      await syncUsersToCloud();
    }
  }

  static bool verifyCurrentPassword(String password) {
    final cleanPassword = password.trim();
    if (isTechAuthenticated) {
      return _currentTechnician!['password']?.toString().trim() == cleanPassword;
    }
    if (_currentUser == null) return false;
    return _currentUser!['password']?.toString().trim() == cleanPassword;
  }

  static void updatePassword(String newPassword) async {
    final cleanPassword = newPassword.trim();
    if (isTechAuthenticated) {
      _currentTechnician!['password'] = cleanPassword;
      _saveCurrentTechnician();
      final techId = _currentTechnician!['id']?.toString() ?? '';
      await DocumentDatabase.updateTechnician(techId, {'password': cleanPassword});
      return;
    }
    if (_currentUser == null) return;
    _currentUser!['password'] = cleanPassword;
    _saveCurrentUser();

    final email = _currentUser!['email']?.toString().toLowerCase().trim();
    final index = _users.indexWhere((u) => u['email']?.toString().toLowerCase().trim() == email);
    if (index != -1) {
      _users[index]['password'] = cleanPassword;
      _saveUsers();
      syncUsersToCloud();
    }
  }
}
