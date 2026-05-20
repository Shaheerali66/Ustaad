import 'dart:convert';
import 'platform_storage.dart';
import 'package:http/http.dart' as http;
import 'user_database.dart';

class DocumentDatabase {
  // Wizard temporary fields
  static String? currentName;
  static String? currentCnic;
  static String? currentPhone;
  static String? currentEmail;
  static String? currentPassword;

  static String? currentCategory;
  static int? currentExperience;
  static String? currentArea;
  static String? currentCity;
  static int? currentRate;

  static String? cnicFront;
  static String? cnicFrontName;
  static int? cnicFrontSize;
  
  static String? cnicBack;
  static String? cnicBackName;
  static int? cnicBackSize;
  
  static String? profilePhoto;
  static String? profilePhotoName;
  static int? profilePhotoSize;
  
  static String? certification;
  static String? certificationName;
  static int? certificationSize;

  // Cloud API Endpoint (Dedicated CORS-enabled JSON database for real-time synchronization between devices)
  static const String _cloudUrl = 'https://jsonbin-zeta.vercel.app/api/bins/eqNEAHiXFT';

  // Cache for loaded technicians
  static List<Map<String, dynamic>>? _cachedTechnicians;

  // Track the last known count for new-application detection
  static int _lastKnownCount = 0;

  // Track known IDs to prevent duplicate alerts
  static Set<String> _knownIds = {};

  // Master database of all onboarded technicians with Local + Cloud Sync
  static List<Map<String, dynamic>> get onboardedTechnicians {
    if (_cachedTechnicians == null) {
      _cachedTechnicians = [];
      _loadFromLocalStorage();
      _ensureDemoWorker();
      syncToCloud();
      _lastKnownCount = _cachedTechnicians!.length;
      _knownIds = _cachedTechnicians!.map((t) => t['id']?.toString() ?? '').toSet();
    }
    return _cachedTechnicians!;
  }

  // Get count of pending applications
  static int get pendingApplicationsCount {
    return onboardedTechnicians.where((t) => t['status'] == 'Pending Approval').length;
  }

  // Get count of new applications since last check
  static int get newApplicationsSinceLastCheck {
    final current = onboardedTechnicians.length;
    final diff = current - _lastKnownCount;
    return diff > 0 ? diff : 0;
  }

  // Reset the "new" counter after admin has seen the notification
  static void acknowledgeNewApplications() {
    _lastKnownCount = onboardedTechnicians.length;
  }

  // Update a technician record by ID securely (Cloud transaction style)
  static Future<bool> updateTechnician(String id, Map<String, dynamic> updatedData) async {
    List<Map<String, dynamic>> targetList = [];
    bool cloudLoaded = false;
    try {
      final response = await http.get(Uri.parse(_cloudUrl));
      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(response.body);
        targetList = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        cloudLoaded = true;
      }
    } catch (_) {}

    if (!cloudLoaded) {
      targetList = List<Map<String, dynamic>>.from(onboardedTechnicians);
    }

    final index = targetList.indexWhere((t) => t['id']?.toString() == id);
    if (index != -1) {
      updatedData.forEach((key, value) {
        targetList[index][key] = value;
      });
      _cachedTechnicians = targetList;
      _ensureDemoWorker();
      persistChanges();

      if (cloudLoaded) {
        try {
          await http.put(
            Uri.parse(_cloudUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(targetList),
          );
        } catch (_) {}
      }
    } else {
      final localList = List<Map<String, dynamic>>.from(onboardedTechnicians);
      final localIdx = localList.indexWhere((t) => t['id']?.toString() == id);
      if (localIdx != -1) {
        updatedData.forEach((key, value) {
          localList[localIdx][key] = value;
        });
        _cachedTechnicians = localList;
        _ensureDemoWorker();
        persistChanges();
        try {
          await http.put(
            Uri.parse(_cloudUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(localList),
          );
        } catch (_) {}
      }
    }
    return true;
  }

  // Load from local storage (initial instant offline load)
  static void _loadFromLocalStorage() {
    try {
      final String? data = PlatformStorage.getString('ustaad_onboarded_technicians_v2');
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        _cachedTechnicians = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (_) {
      // Silent fail — will use defaults
    }
    
    // Seed default values if completely empty
    if (_cachedTechnicians == null || _cachedTechnicians!.isEmpty) {
      _cachedTechnicians = _getDefaultSeeds();
    }
    _ensureDemoWorker();
    persistChanges();
  }

  static void _ensureDemoWorker() {
    if (_cachedTechnicians == null) return;
    final demoEmail = 'admin12345@gmail.com';
    final index = _cachedTechnicians!.indexWhere((t) => t['email']?.toString().toLowerCase().trim() == demoEmail);
    final demoAccount = {
      'id': '100',
      'name': 'Demo Worker',
      'email': demoEmail,
      'password': 'Admin0011',
      'cnic': '35201-0000000-1',
      'phone': '03000000000',
      'category': 'AC Technician',
      'experience': 5,
      'area': 'F-7',
      'city': 'Islamabad',
      'hourlyRate': 1000,
      'status': 'Approved',
      'cnicFrontName': 'cnic_front.jpg',
      'cnicBackName': 'cnic_back.jpg',
      'profilePhotoName': 'profile.jpg',
      'certificationName': 'cert.pdf',
      'adminNotes': '',
      'role': 'worker',
    };
    if (index == -1) {
      _cachedTechnicians!.add(demoAccount);
    } else {
      final existing = _cachedTechnicians![index];
      if (existing['name'] != 'Demo Worker' ||
          existing['password'] != 'Admin0011' ||
          existing['status'] != 'Approved' ||
          existing['category'] != 'AC Technician' ||
          existing['city'] != 'Islamabad') {
        _cachedTechnicians![index] = demoAccount;
      }
    }
  }

  // Seed default technicians
  static List<Map<String, dynamic>> _getDefaultSeeds() {
    return [
      {
        'id': '101',
        'name': 'Ali Ansari',
        'cnic': '35201-9876543-1',
        'phone': '0300 9876543',
        'category': 'AC Technician',
        'experience': 5,
        'area': 'Sector G-13',
        'city': 'Islamabad',
        'hourlyRate': 1200,
        'status': 'Approved',
        'cnicFrontName': 'cnic_front.jpg',
        'cnicBackName': 'cnic_back.jpg',
        'profilePhotoName': 'ali_avatar.jpg',
        'certificationName': 'hvac_cert.pdf',
        'adminNotes': '',
        'role': 'worker',
      },
      {
        'id': '102',
        'name': 'Bilal Siddiqui',
        'cnic': '35202-1234567-3',
        'phone': '0321 4567890',
        'category': 'Plumber',
        'experience': 4,
        'area': 'Sector F-11',
        'city': 'Islamabad',
        'hourlyRate': 950,
        'status': 'Approved',
        'cnicFrontName': 'bilal_cnic_front.jpg',
        'cnicBackName': 'bilal_cnic_back.jpg',
        'profilePhotoName': 'bilal.png',
        'certificationName': 'plumbing_diploma.pdf',
        'adminNotes': '',
        'role': 'worker',
      }
    ];
  }

  // Save changes locally
  static void persistChanges() {
    try {
      if (_cachedTechnicians != null) {
        PlatformStorage.setString('ustaad_onboarded_technicians_v2', jsonEncode(_cachedTechnicians));
      }
    } catch (_) {
      // Silent fail
    }
  }

  // Push all local modifications to Cloud Database asynchronously
  static Future<bool> syncToCloud() async {
    try {
      final listToUpload = onboardedTechnicians;
      final response = await http.put(
        Uri.parse(_cloudUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(listToUpload),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // Pull latest registrations from Cloud Database
  // Returns a SyncResult with success status and list of new entries
  static Future<SyncResult> syncFromCloudWithInfo() async {
    try {
      final response = await http.get(Uri.parse(_cloudUrl));
      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(response.body);
        if (decoded.isNotEmpty) {
          final cloudList = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          
          // Initialize known IDs if not done yet
          if (_knownIds.isEmpty) {
            _knownIds = onboardedTechnicians.map((t) => t['id']?.toString() ?? '').toSet();
          }

          // Detect new entries using unique IDs
          final List<Map<String, dynamic>> newEntries = [];
          for (var item in cloudList) {
            final String id = item['id']?.toString() ?? '';
            if (id.isNotEmpty && !_knownIds.contains(id)) {
              if (item['status'] == 'Pending Approval') {
                newEntries.add(item);
              }
              _knownIds.add(id);
            }
          }

          _cachedTechnicians = cloudList;
          _ensureDemoWorker();
          _cachedTechnicians!.sort((a, b) {
            final int idA = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
            final int idB = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
            return idA.compareTo(idB);
          });

          persistChanges();
          _lastKnownCount = _cachedTechnicians!.length;

          return SyncResult(success: true, newEntries: newEntries);
        }
      }
      return SyncResult(success: false, newEntries: []);
    } catch (_) {
      return SyncResult(success: false, newEntries: []);
    }
  }

  // Legacy syncFromCloud for backwards compatibility
  static Future<bool> syncFromCloud() async {
    final result = await syncFromCloudWithInfo();
    return result.success;
  }

  static void saveDocuments({
    String? front,
    String? frontName,
    int? frontSize,
    String? back,
    String? backName,
    int? backSize,
    String? profile,
    String? profileName,
    int? profileSize,
    String? cert,
    String? certName,
    int? certSize,
  }) {
    cnicFront = front;
    cnicFrontName = frontName;
    cnicFrontSize = frontSize;
    
    cnicBack = back;
    cnicBackName = backName;
    cnicBackSize = backSize;
    
    profilePhoto = profile;
    profilePhotoName = profileName;
    profilePhotoSize = profileSize;
    
    certification = cert;
    certificationName = certName;
    certificationSize = certSize;
  }

  static Future<bool> addOnboardedTechnician() async {
    List<Map<String, dynamic>> list = [];
    bool cloudFetchSuccess = false;
    try {
      final response = await http.get(Uri.parse(_cloudUrl));
      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(response.body);
        list = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        cloudFetchSuccess = true;
      }
    } catch (_) {
      // Fallback to local
    }

    if (!cloudFetchSuccess) {
      list = List<Map<String, dynamic>>.from(onboardedTechnicians);
    }

    final email = currentEmail?.toLowerCase().trim() ?? '';
    final cleanPassword = currentPassword?.trim() ?? 'N/A';
    if (email.isNotEmpty) {
      await UserDatabase.syncUsersFromCloud();
      final hasCustomer = UserDatabase.users.any((u) => u['email']?.toString().toLowerCase().trim() == email);
      final hasWorker = list.any((t) => t['email']?.toString().toLowerCase().trim() == email);
      if (hasCustomer || hasWorker) {
        return false; // Email already registered!
      }
    }

    // Generate a unique ID based on max ID in the list
    int maxId = 100;
    for (var tech in list) {
      final idInt = int.tryParse(tech['id']?.toString() ?? '');
      if (idInt != null && idInt > maxId) {
        maxId = idInt;
      }
    }
    final newId = (maxId + 1).toString();

    final newTech = {
      'id': newId,
      'name': currentName ?? 'New Technician',
      'email': email.isNotEmpty ? email : 'N/A',
      'password': cleanPassword,
      'cnic': currentCnic ?? 'N/A',
      'phone': currentPhone ?? 'N/A',
      'category': currentCategory ?? 'General Trades',
      'experience': currentExperience ?? 3,
      'area': currentArea ?? 'Sector G-11',
      'city': currentCity ?? 'Islamabad',
      'hourlyRate': currentRate ?? 1000,
      'status': 'Pending Approval',
      'adminNotes': '',
      'role': 'worker',
      // Dynamic base64 documents & metadata
      'cnicFront': cnicFront,
      'cnicFrontName': cnicFrontName,
      'cnicFrontSize': cnicFrontSize,
      'cnicBack': cnicBack,
      'cnicBackName': cnicBackName,
      'cnicBackSize': cnicBackSize,
      'profilePhoto': profilePhoto,
      'profilePhotoName': profilePhotoName,
      'profilePhotoSize': profilePhotoSize,
      'certification': certification,
      'certificationName': certificationName,
      'certificationSize': certificationSize,
    };

    list.add(newTech);

    // Save locally
    _cachedTechnicians = list;
    persistChanges();

    // Clear temporary wizard variables
    currentName = null;
    currentEmail = null;
    currentPassword = null;
    currentCnic = null;
    currentPhone = null;
    currentCategory = null;
    currentExperience = null;
    currentArea = null;
    currentCity = null;
    currentRate = null;
    cnicFront = null;
    cnicFrontName = null;
    cnicFrontSize = null;
    cnicBack = null;
    cnicBackName = null;
    cnicBackSize = null;
    profilePhoto = null;
    profilePhotoName = null;
    profilePhotoSize = null;
    certification = null;
    certificationName = null;
    certificationSize = null;

    try {
      // Put back to cloud asynchronously
      await http.put(
        Uri.parse(_cloudUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(list),
      );
    } catch (_) {
      // Fail silently to keep application running offline
    }

    return true; // Always succeed locally
  }
}

// Result class for sync operations
class SyncResult {
  final bool success;
  final List<Map<String, dynamic>> newEntries;

  SyncResult({required this.success, required this.newEntries});
}
