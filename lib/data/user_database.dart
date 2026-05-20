import 'dart:convert';
import 'document_database.dart';
import 'package:universal_html/html.dart' as html;
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
            _saveUsers();
          }
          await syncUsersToCloud();
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static void init() {
    try {
      // Load users
      final usersData = html.window.localStorage[_usersKey];
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
      final currentUserData = html.window.localStorage[_currentUserKey];
      if (currentUserData != null && currentUserData.trim().isNotEmpty) {
        _currentUser = jsonDecode(currentUserData);
      }

      // Load current logged-in technician
      final currentTechData = html.window.localStorage[_currentTechKey];
      if (currentTechData != null && currentTechData.trim().isNotEmpty) {
        _currentTechnician = jsonDecode(currentTechData);
      }

      // Load first login flag
      final firstLoginData = html.window.localStorage[_firstLoginKey];
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
    syncUsersFromCloud();
  }

  static bool get isAuthenticated => _currentUser != null;

  static Map<String, dynamic>? get currentUser => _currentUser;

  static bool get isTechAuthenticated => _currentTechnician != null;

  static Map<String, dynamic>? get currentTechnician => _currentTechnician;

  static void _saveCurrentTechnician() {
    try {
      if (_currentTechnician != null) {
        html.window.localStorage[_currentTechKey] = jsonEncode(_currentTechnician);
      } else {
        html.window.localStorage.remove(_currentTechKey);
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
      html.window.localStorage[_firstLoginKey] = 'false';
    } catch (_) {}
  }

  static void _saveUsers() {
    try {
      html.window.localStorage[_usersKey] = jsonEncode(_users);
    } catch (_) {}
  }

  static void _saveCurrentUser() {
    try {
      if (_currentUser != null) {
        html.window.localStorage[_currentUserKey] = jsonEncode(_currentUser);
      } else {
        html.window.localStorage.remove(_currentUserKey);
      }
    } catch (_) {}
  }

  static bool login(String email, String password) {
    init(); // Ensure loaded
    final index = _users.indexWhere(
      (u) => u['email']?.toString().toLowerCase().trim() == email.trim().toLowerCase() && u['password']?.toString() == password
    );
    if (index != -1) {
      _currentUser = Map<String, dynamic>.from(_users[index]);
      _isFirstLoginAfterSignup = false;
      try {
        html.window.localStorage[_firstLoginKey] = 'false';
      } catch (_) {}
      _saveCurrentUser();
      return true;
    }
    return false;
  }

  static Future<bool> signup(Map<String, dynamic> userData) async {
    await syncUsersFromCloud();
    await DocumentDatabase.syncFromCloud();
    final email = userData['email']?.toString().toLowerCase().trim() ?? '';
    
    // Check customers
    final hasCustomer = _users.any((u) => u['email']?.toString().toLowerCase().trim() == email);
    // Check workers
    final hasWorker = DocumentDatabase.onboardedTechnicians.any((t) => t['email']?.toString().toLowerCase().trim() == email);
    
    if (hasCustomer || hasWorker) {
      return false; // Email already exists
    }

    final newUserData = Map<String, dynamic>.from(userData);
    newUserData['role'] = 'customer';
    _users.add(newUserData);
    _saveUsers();
    await syncUsersToCloud();

    // Automatically log in
    _currentUser = newUserData;
    _isFirstLoginAfterSignup = true;
    try {
      html.window.localStorage[_firstLoginKey] = 'true';
    } catch (_) {}
    _saveCurrentUser();
    return true;
  }

  static void logout() {
    _currentUser = null;
    _isFirstLoginAfterSignup = false;
    _saveCurrentUser();
    try {
      html.window.localStorage.remove(_currentUserKey);
      html.window.localStorage.remove(_firstLoginKey);
    } catch (_) {}
  }

  static Future<void> updateProfile(Map<String, dynamic> updatedData) async {
    if (_currentUser == null) return;
    
    await syncUsersFromCloud();

    // Update local currentUser
    updatedData.forEach((key, value) {
      _currentUser![key] = value;
    });
    _saveCurrentUser();

    // Update in users list
    final email = _currentUser!['email']?.toString().toLowerCase().trim();
    final index = _users.indexWhere((u) => u['email']?.toString().toLowerCase().trim() == email);
    if (index != -1) {
      updatedData.forEach((key, value) {
        _users[index][key] = value;
      });
      _saveUsers();
      await syncUsersToCloud();
    }
  }

  static bool verifyCurrentPassword(String password) {
    if (isTechAuthenticated) {
      return _currentTechnician!['password']?.toString() == password;
    }
    if (_currentUser == null) return false;
    return _currentUser!['password']?.toString() == password;
  }

  static void updatePassword(String newPassword) async {
    if (isTechAuthenticated) {
      _currentTechnician!['password'] = newPassword;
      _saveCurrentTechnician();
      final techId = _currentTechnician!['id']?.toString() ?? '';
      await DocumentDatabase.updateTechnician(techId, {'password': newPassword});
      return;
    }
    if (_currentUser == null) return;
    _currentUser!['password'] = newPassword;
    _saveCurrentUser();

    final email = _currentUser!['email']?.toString().toLowerCase().trim();
    final index = _users.indexWhere((u) => u['email']?.toString().toLowerCase().trim() == email);
    if (index != -1) {
      _users[index]['password'] = newPassword;
      _saveUsers();
      syncUsersToCloud();
    }
  }
}
