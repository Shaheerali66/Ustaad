import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../data/document_database.dart';

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;
  final double borderRadius;

  DashedBorderPainter({
    this.color = Colors.grey,
    this.strokeWidth = 1.5,
    this.gap = 4.0,
    this.dashLength = 6.0,
    this.borderRadius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    final dashedPath = Path();
    for (final pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < pathMetric.length) {
        final len = draw ? dashLength : gap;
        if (draw) {
          dashedPath.addPath(
            pathMetric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.borderRadius != borderRadius;
  }
}

class TechDocumentsScreen extends StatefulWidget {
  const TechDocumentsScreen({super.key});

  @override
  State<TechDocumentsScreen> createState() => _TechDocumentsScreenState();
}

class _TechDocumentsScreenState extends State<TechDocumentsScreen> {
  bool _isSubmitting = false;
  bool _agreedToTerms = false;
  bool _showErrors = false;

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

  void _onSubmitTap() {
    final List<String> missing = [];
    if (profilePhotoFile == null) missing.add('Profile Photo');
    if (cnicFrontFile == null) missing.add('CNIC Front Photo');
    if (cnicBackFile == null) missing.add('CNIC Back Photo');
    if (!_agreedToTerms) missing.add('Terms of Service Agreement');

    if (missing.isNotEmpty) {
      setState(() {
        _showErrors = true;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete the following before submitting: ${missing.join(", ")}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    _submitApplication();
  }

  void _submitApplication() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

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

    // Upload to cloud real-time database
    final success = await DocumentDatabase.addOnboardedTechnician();

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully! Stored in master cloud database.'),
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/technician/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection failed. Please check your internet connection and try again.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatSize(int? bytes) {
    if (bytes == null) return '0 KB';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  void _showTermsDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Text(
            'By submitting this application, you verify that all details provided are complete, accurate, and correct. You agree to cooperate with local service policies and standard background inspection checks required for technician validation.',
            style: GoogleFonts.inter(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.primary)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool step3Complete = profilePhotoFile != null && cnicFrontFile != null && cnicBackFile != null && _agreedToTerms;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: Text('Document Verification', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        actions: [
          IconButton(
            icon: const Icon(Icons.dns),
            onPressed: () => _showDatabaseDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Progress
          Row(children: [
            Expanded(child: Container(height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(width: 4),
            Expanded(child: Container(height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(width: 4),
            Expanded(child: Container(height: 4, decoration: BoxDecoration(color: step3Complete ? AppColors.primary : AppColors.surfaceVariant, borderRadius: BorderRadius.circular(2)))),
          ]),
          const SizedBox(height: 8),
          Center(child: Text('Step 3 of 3', style: GoogleFonts.inter(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600))),
          const SizedBox(height: 16),
          Text('Upload clear photos of your documents to complete your profile. This helps us ensure a secure environment.', style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurface)),
          const SizedBox(height: 24),

          // Profile Photo
          _buildUploadField(
            title: 'Profile Photo',
            label: 'Take Face Photo',
            fileData: profilePhotoFile,
            fileName: profilePhotoName,
            fileSize: profilePhotoSize,
            errorMsg: 'Profile photo is required. Please upload a clear face photo to proceed.',
            isMandatory: true,
            icon: Icons.camera_alt_outlined,
            onTap: () {
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
            onClear: () {
              setState(() {
                profilePhotoFile = null;
                profilePhotoName = null;
                profilePhotoSize = null;
              });
            },
          ),
          const SizedBox(height: 20),

          // CNIC Front
          _buildUploadField(
            title: 'CNIC Front Side',
            label: 'Upload CNIC Front',
            fileData: cnicFrontFile,
            fileName: cnicFrontName,
            fileSize: cnicFrontSize,
            errorMsg: 'CNIC front photo is required. Please upload to proceed.',
            isMandatory: true,
            icon: Icons.add_photo_alternate_outlined,
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
          const SizedBox(height: 20),

          // CNIC Back
          _buildUploadField(
            title: 'CNIC Back Side',
            label: 'Upload CNIC Back',
            fileData: cnicBackFile,
            fileName: cnicBackName,
            fileSize: cnicBackSize,
            errorMsg: 'CNIC back photo is required. Please upload to proceed.',
            isMandatory: true,
            icon: Icons.add_photo_alternate_outlined,
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
          const SizedBox(height: 20),

          // Professional Certification (Optional)
          _buildUploadField(
            title: 'Professional Certification',
            label: 'Upload Document (PDF/JPG)',
            fileData: certFile,
            fileName: certName,
            fileSize: certSize,
            errorMsg: '',
            isMandatory: false,
            icon: Icons.upload_file_outlined,
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
            onClear: () {
              setState(() {
                certFile = null;
                certName = null;
                certSize = null;
              });
            },
          ),
          const SizedBox(height: 24),

          // Terms and Conditions checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _agreedToTerms,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() {
                    _agreedToTerms = val ?? false;
                  });
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Wrap(
                    children: [
                      Text('I agree to the ', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface)),
                      GestureDetector(
                        onTap: () => _showTermsDialog('Terms of Service'),
                        child: Text('Terms of Service', style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                      Text(' and verify the accuracy of all submitted info.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_showErrors && !_agreedToTerms) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: Text(
                'You must agree to the Terms of Service to proceed.',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error),
              ),
            ),
          ],
          const SizedBox(height: 32),

          // Submit Application
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _onSubmitTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: step3Complete ? AppColors.primary : AppColors.surfaceContainerHigh,
                foregroundColor: step3Complete ? Colors.white : AppColors.onSurfaceVariant,
                elevation: step3Complete ? 2 : 0,
                shadowColor: step3Complete ? null : Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Submit Application', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.auto_awesome, size: 14, color: AppColors.tertiaryFixedDim), const SizedBox(width: 4), Text('AI-powered verification processes documents securely.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant))])),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _buildUploadField({
    required String title,
    required String label,
    required String? fileData,
    required String? fileName,
    required int? fileSize,
    required String errorMsg,
    required bool isMandatory,
    required IconData icon,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    final bool hasData = fileData != null;
    final bool showError = _showErrors && isMandatory && !hasData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            if (isMandatory)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.errorContainer.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                child: Text('REQUIRED', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.error)),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(4)),
                child: Text('OPTIONAL', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.onSurfaceVariant)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (hasData)
          // Uploaded state
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade400, width: 1.5),
            ),
            child: Row(
              children: [
                // Thumbnail with green checkmark badge overlay
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: (fileName?.toLowerCase().endsWith('.jpg') == true ||
                                fileName?.toLowerCase().endsWith('.jpeg') == true ||
                                fileName?.toLowerCase().endsWith('.png') == true ||
                                fileData.startsWith('data:image/'))
                            ? Image.memory(
                                base64Decode(fileData.split(',').last),
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: AppColors.surfaceContainerLow,
                                child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
                              ),
                      ),
                    ),
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName ?? 'Uploaded File',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatSize(fileSize),
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.refresh, size: 16, color: AppColors.primary),
                  label: Text('Change', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: onClear,
                ),
              ],
            ),
          )
        else
          // Empty or Error state
          GestureDetector(
            onTap: onTap,
            child: CustomPaint(
              painter: DashedBorderPainter(
                color: showError ? AppColors.error : AppColors.outlineVariant,
                strokeWidth: 1.5,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: showError ? AppColors.errorContainer.withOpacity(0.05) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      showError ? Icons.warning_amber_rounded : icon,
                      color: showError ? AppColors.error : AppColors.onSurfaceVariant,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: showError ? AppColors.error : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      showError ? 'Validation failed' : 'Max size 5MB (JPG, PNG)',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: showError ? AppColors.error : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (showError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorMsg,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error),
            ),
          ),
        ],
      ],
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
