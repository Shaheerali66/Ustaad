import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../data/document_database.dart';

class TechDocumentsScreen extends StatefulWidget {
  const TechDocumentsScreen({super.key});

  @override
  State<TechDocumentsScreen> createState() => _TechDocumentsScreenState();
}

class _TechDocumentsScreenState extends State<TechDocumentsScreen> {
  String? cnicFrontFile;
  String? cnicFrontName;
  int? cnicFrontSize;

  String? cnicBackFile;
  String? cnicBackName;
  int? cnicBackSize;

  String? profilePhotoFile;
  String? profilePhotoName;
  int? profilePhotoSize;

  String? certFile;
  String? certName;
  int? certSize;

  @override
  void initState() {
    super.initState();
    // Load pre-existing data from database if any
    cnicFrontFile = DocumentDatabase.cnicFront;
    cnicFrontName = DocumentDatabase.cnicFrontName;
    cnicFrontSize = DocumentDatabase.cnicFrontSize;

    cnicBackFile = DocumentDatabase.cnicBack;
    cnicBackName = DocumentDatabase.cnicBackName;
    cnicBackSize = DocumentDatabase.cnicBackSize;

    profilePhotoFile = DocumentDatabase.profilePhoto;
    profilePhotoName = DocumentDatabase.profilePhotoName;
    profilePhotoSize = DocumentDatabase.profilePhotoSize;

    certFile = DocumentDatabase.certification;
    certName = DocumentDatabase.certificationName;
    certSize = DocumentDatabase.certificationSize;
  }

  void _pickFile({
    required String accept,
    bool capture = false,
    required Function(String base64, String name, int size) onPicked,
  }) {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = accept;
    if (capture) {
      uploadInput.setAttribute('capture', 'user');
    }
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final size = file.size;

        // 5MB Size Validation (5 * 1024 * 1024 bytes)
        if (size > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File size must be less than 5MB (Selected file is ${(size / (1024 * 1024)).toStringAsFixed(2)}MB)'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((e) {
          final result = reader.result;
          if (result is String) {
            onPicked(result, file.name, size);
          }
        });
      }
    });
  }

  void _downloadFile(String? base64, String? name) {
    if (base64 == null || name == null) return;
    final anchor = html.AnchorElement(href: base64)
      ..setAttribute('download', name)
      ..style.display = 'none';
    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
  }

  void _submitApplication() {
    // Save to Database
    DocumentDatabase.saveDocuments(
      front: cnicFrontFile,
      frontName: cnicFrontName,
      frontSize: cnicFrontSize,
      back: cnicBackFile,
      backName: cnicBackName,
      backSize: cnicBackSize,
      profile: profilePhotoFile,
      profileName: profilePhotoName,
      profileSize: profilePhotoSize,
      cert: certFile,
      certName: certName,
      certSize: certSize,
    );

    // Merge into the global onboarded list!
    DocumentDatabase.addOnboardedTechnician();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Application submitted successfully! Stored in master backend directory.'),
        backgroundColor: Colors.teal,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.go('/technician/home');
  }

  String _formatSize(int? bytes) {
    if (bytes == null) return '0 KB';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: Text('Document Verification', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Progress
          Row(children: List.generate(3, (i) => Expanded(child: Container(margin: EdgeInsets.only(right: i < 2 ? 4 : 0), height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)))))),
          const SizedBox(height: 8),
          Center(child: Text('Step 3 of 3', style: GoogleFonts.inter(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600))),
          const SizedBox(height: 16),
          Text('Upload clear photos of your documents to complete your profile. This helps us ensure a secure environment.', style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurface)),
          const SizedBox(height: 24),
          
          // CNIC Front
          _buildDocCard(
            title: 'CNIC Front Side',
            sub: 'Clear photo, all text visible',
            fileData: cnicFrontFile,
            fileName: cnicFrontName,
            fileSize: cnicFrontSize,
            icon: Icons.badge,
            onTap: () {
              _pickFile(
                accept: 'image/jpeg, image/jpg, image/png',
                onPicked: (base64, name, size) {
                  setState(() {
                    cnicFrontFile = base64;
                    cnicFrontName = name;
                    cnicFrontSize = size;
                  });
                },
              );
            },
            onClear: () {
              setState(() {
                cnicFrontFile = null;
                cnicFrontName = null;
                cnicFrontSize = null;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // CNIC Back
          _buildDocCard(
            title: 'CNIC Back Side',
            sub: 'Clear photo, signature visible',
            fileData: cnicBackFile,
            fileName: cnicBackName,
            fileSize: cnicBackSize,
            icon: Icons.badge,
            onTap: () {
              _pickFile(
                accept: 'image/jpeg, image/jpg, image/png',
                onPicked: (base64, name, size) {
                  setState(() {
                    cnicBackFile = base64;
                    cnicBackName = name;
                    cnicBackSize = size;
                  });
                },
              );
            },
            onClear: () {
              setState(() {
                cnicBackFile = null;
                cnicBackName = null;
                cnicBackSize = null;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Profile Photo (Camera Capture)
          Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceVariant)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Expanded(child: Text('Profile Photo', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600))), const Icon(Icons.tag_faces, color: AppColors.onSurfaceVariant)]),
              Text('Clear face shot, solid background', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 12),
              Row(children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.surfaceContainerLow,
                  backgroundImage: profilePhotoFile != null
                      ? MemoryImage(base64Decode(profilePhotoFile!.split(',').last))
                      : null,
                  child: profilePhotoFile == null
                      ? const Icon(Icons.person_outline, size: 28, color: AppColors.onSurfaceVariant)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (profilePhotoFile != null) ...[
                        Text(
                          profilePhotoName ?? 'profile_photo.jpg',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatSize(profilePhotoSize),
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant),
                        ),
                      ] else ...[
                        Text(
                          'No photo taken',
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (profilePhotoFile != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        profilePhotoFile = null;
                        profilePhotoName = null;
                        profilePhotoSize = null;
                      });
                    },
                  ),
                OutlinedButton.icon(
                  onPressed: () {
                    _pickFile(
                      accept: 'image/*',
                      capture: true,
                      onPicked: (base64, name, size) {
                        setState(() {
                          profilePhotoFile = base64;
                          profilePhotoName = name;
                          profilePhotoSize = size;
                        });
                      },
                    );
                  },
                  icon: const Icon(Icons.camera_alt, size: 16),
                  label: Text(profilePhotoFile == null ? 'Take Photo' : 'Retake', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size(0, 36),
                  ),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          
          // Certification (Optional PDF/JPEG)
          Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceVariant)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Row(children: [Text('Professional Certification', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(9999)), child: Text('OPTIONAL', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)))])),
                const Icon(Icons.workspace_premium, color: AppColors.onSurfaceVariant),
              ]),
              Text('Boosts your profile ranking', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 12),
              
              if (certFile != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        certName?.toLowerCase().endsWith('.pdf') == true
                            ? Icons.picture_as_pdf
                            : Icons.insert_drive_file,
                        color: certName?.toLowerCase().endsWith('.pdf') == true
                            ? Colors.red.shade700
                            : AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              certName ?? 'document.pdf',
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _formatSize(certSize),
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            certFile = null;
                            certName = null;
                            certSize = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ] else ...[
                GestureDetector(
                  onTap: () {
                    _pickFile(
                      accept: 'application/pdf, image/jpeg, image/jpg, image/png',
                      onPicked: (base64, name, size) {
                        setState(() {
                          certFile = base64;
                          certName = name;
                          certSize = size;
                        });
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.outlineVariant, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.upload_file, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text('Upload Document (PDF/JPG)', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 24),
          
          // Submit Application
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitApplication,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text('Submit Application', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.auto_awesome, size: 14, color: AppColors.tertiaryFixedDim), const SizedBox(width: 4), Text('AI-powered verification processes documents securely.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant))])),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _buildDocCard({
    required String title,
    required String sub,
    required String? fileData,
    required String? fileName,
    required int? fileSize,
    required IconData icon,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    final bool uploaded = fileData != null;
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600))), Icon(icon, color: AppColors.onSurfaceVariant)]),
        Text(sub, style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 12),
        if (uploaded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                // Render image thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Image.memory(
                      base64Decode(fileData!.split(',').last),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName ?? 'upload.jpg',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatSize(fileSize),
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onClear,
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary, style: BorderStyle.solid)),
              child: Column(children: [const Icon(Icons.add_photo_alternate, color: AppColors.primary), const SizedBox(height: 4), Text('Tap to Upload', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary))]),
            ),
          ),
      ]),
    );
  }

  void _showDatabaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.dns, color: Colors.green),
              const SizedBox(width: 8),
              Text('Live Base64 Database Inspector', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildDbItem('CNIC Front Side', cnicFrontFile, cnicFrontName, cnicFrontSize),
                const Divider(),
                _buildDbItem('CNIC Back Side', cnicBackFile, cnicBackName, cnicBackSize),
                const Divider(),
                _buildDbItem('Profile Photo', profilePhotoFile, profilePhotoName, profilePhotoSize),
                const Divider(),
                _buildDbItem('Professional Cert', certFile, certName, certSize),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Close Inspector', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDbItem(String label, String? base64, String? name, int? size) {
    final bool hasData = base64 != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: hasData ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  hasData ? 'STORED' : 'EMPTY',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: hasData ? Colors.green.shade800 : Colors.red.shade800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (hasData) ...[
            Text('File Name: $name', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
            Text('File Size: ${_formatSize(size)}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _downloadFile(base64, name),
                  icon: const Icon(Icons.download, size: 14, color: AppColors.primary),
                  label: Text('Download File', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Byte Stream: ${base64.substring(0, 30)}...',
                    style: GoogleFonts.inter(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ] else ...[
            Text('No document has been selected or uploaded yet.', style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}
