import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

class UserDatabase {
  static List<Map<String, dynamic>> _users = [];
  static Map<String, dynamic>? _currentUser;
  static bool _isFirstLoginAfterSignup = false;

  static const String _usersKey = 'khidmat_registered_users_v1';
  static const String _currentUserKey = 'khidmat_current_user_v1';
  static const String _firstLoginKey = 'khidmat_first_login_flag_v1';
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
          }
        ];
        _saveUsers();
      }

      // Load current logged-in user
      final currentUserData = html.window.localStorage[_currentUserKey];
      if (currentUserData != null && currentUserData.trim().isNotEmpty) {
        _currentUser = jsonDecode(currentUserData);
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
        }
      ];
    }
    syncUsersFromCloud();
  }

  static bool get isAuthenticated => _currentUser != null;

  static Map<String, dynamic>? get currentUser => _currentUser;

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

  static bool signup(Map<String, dynamic> userData) {
    init(); // Ensure loaded
    final email = userData['email']?.toString().toLowerCase().trim() ?? '';
    final index = _users.indexWhere((u) => u['email']?.toString().toLowerCase().trim() == email);
    if (index != -1) {
      return false; // Email already exists
    }

    final newUserData = Map<String, dynamic>.from(userData);
    _users.add(newUserData);
    _saveUsers();
    syncUsersToCloud();

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

  static void updateProfile(Map<String, dynamic> updatedData) {
    if (_currentUser == null) return;
    
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
      syncUsersToCloud();
    }
  }

  static bool verifyCurrentPassword(String password) {
    if (_currentUser == null) return false;
    return _currentUser!['password']?.toString() == password;
  }

  static void updatePassword(String newPassword) {
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
