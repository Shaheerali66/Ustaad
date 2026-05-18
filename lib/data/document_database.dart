import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

class DocumentDatabase {
  // Wizard temporary fields
  static String? currentName;
  static String? currentCnic;
  static String? currentPhone;

  static String? currentCategory;
  static int? currentExperience;
  static String? currentArea;
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

  // Master database of all onboarded technicians with Local + Cloud Sync
  static List<Map<String, dynamic>> get onboardedTechnicians {
    if (_cachedTechnicians == null) {
      _cachedTechnicians = [];
      _loadFromLocalStorage();
    }
    return _cachedTechnicians!;
  }

  // Load from LocalStorage (initial instant offline load)
  static void _loadFromLocalStorage() {
    try {
      final String? data = html.window.localStorage['khidmat_onboarded_technicians_v2'];
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        _cachedTechnicians = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print('Error loading from local storage: $e');
    }
    
    // Seed default values if completely empty
    if (_cachedTechnicians == null || _cachedTechnicians!.isEmpty) {
      _cachedTechnicians = _getDefaultSeeds();
      persistChanges();
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
      }
    ];
  }

  // Save changes locally to LocalStorage
  static void persistChanges() {
    try {
      if (_cachedTechnicians != null) {
        html.window.localStorage['khidmat_onboarded_technicians_v2'] = jsonEncode(_cachedTechnicians);
      }
    } catch (e) {
      print('Error saving to local storage: $e');
    }
  }

  // Push all local modifications to Cloud Database asynchronously (Using HTTP PUT for direct JSONBin updates)
  static Future<bool> syncToCloud() async {
    try {
      final listToUpload = onboardedTechnicians;
      final response = await http.put(
        Uri.parse(_cloudUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(listToUpload),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Cloud Sync successful (Pushed).');
        return true;
      } else {
        print('Cloud Sync failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Network error syncing to cloud: $e');
      return false;
    }
  }

  // Pull latest registrations from Cloud Database
  static Future<bool> syncFromCloud() async {
    try {
      final response = await http.get(Uri.parse(_cloudUrl));
      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(response.body);
        if (decoded.isNotEmpty) {
          final cloudList = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          
          // Merge local pending additions into the cloud list if they are not in the cloud yet
          final Map<String, Map<String, dynamic>> mergedMap = {};
          
          // 1. Add all from cloud
          for (var item in cloudList) {
            final String? id = item['id']?.toString();
            if (id != null) {
              mergedMap[id] = item;
            }
          }
          
          // 2. Add local defaults and dynamic ones
          final currentLocal = onboardedTechnicians;
          for (var item in currentLocal) {
            final String? id = item['id']?.toString();
            if (id != null && !mergedMap.containsKey(id)) {
              mergedMap[id] = item;
            }
          }

          _cachedTechnicians = mergedMap.values.toList();
          
          // Sort by ID to keep order clean
          _cachedTechnicians!.sort((a, b) {
            final int idA = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
            final int idB = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
            return idA.compareTo(idB);
          });

          persistChanges();
          print('Cloud Sync successful (Pulled). Length: ${_cachedTechnicians!.length}');
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Network error pulling from cloud: $e');
      return false;
    }
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

  static void addOnboardedTechnician() {
    final list = onboardedTechnicians;
    
    list.add({
      'id': (list.length + 101).toString(),
      'name': currentName ?? 'New Technician',
      'cnic': currentCnic ?? 'N/A',
      'phone': currentPhone ?? 'N/A',
      'category': currentCategory ?? 'General Trades',
      'experience': currentExperience ?? 3,
      'area': currentArea ?? 'Sector G-11',
      'city': 'Islamabad',
      'hourlyRate': currentRate ?? 1000,
      'status': 'Pending Approval',
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
    });
    
    // 1. Save changes locally immediately
    persistChanges();
    
    // 2. Push to cloud database in the background to sync with all other devices instantly!
    syncToCloud();
    
    // Clear temporary wizard variables
    currentName = null;
    currentCnic = null;
    currentPhone = null;
    currentCategory = null;
    currentExperience = null;
    currentArea = null;
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
  }
}
