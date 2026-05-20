import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../utils/google_maps_service.dart';

class GooglePlacesAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSelected;
  final int maxLines;
  final int minLines;

  const GooglePlacesAutocompleteField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon = Icons.location_on_outlined,
    this.validator,
    this.onChanged,
    this.onSelected,
    this.maxLines = 1,
    this.minLines = 1,
  });

  @override
  State<GooglePlacesAutocompleteField> createState() => _GooglePlacesAutocompleteFieldState();
}

class _GooglePlacesAutocompleteFieldState extends State<GooglePlacesAutocompleteField> {
  Timer? _debounce;

  Future<List<String>> _getSuggestions(String query) async {
    if (query.trim().isEmpty || query.trim().length < 3) return [];
    
    final suggestions = await GoogleMapsService.getPlaceSuggestions(query);
    return suggestions.map((item) => item['description'] ?? '').toList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) async {
            if (textEditingValue.text.trim().isEmpty) {
              return const Iterable<String>.empty();
            }
            return await _getSuggestions(textEditingValue.text);
          },
          onSelected: (String selection) {
            widget.controller.text = selection;
            if (widget.onSelected != null) {
              widget.onSelected!(selection);
            }
          },
          fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
            // Synchronize widget controller and autocomplete controller
            if (textController.text != widget.controller.text) {
              textController.text = widget.controller.text;
            }

            textController.addListener(() {
              if (widget.controller.text != textController.text) {
                widget.controller.text = textController.text;
                if (widget.onChanged != null) {
                  widget.onChanged!(textController.text);
                }
              }
            });

            return TextFormField(
              controller: textController,
              focusNode: focusNode,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
                prefixIcon: Icon(widget.prefixIcon, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              validator: widget.validator,
              onFieldSubmitted: (_) => onFieldSubmitted(),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                child: Container(
                  width: constraints.maxWidth,
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceVariant),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.surfaceVariant),
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        leading: const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                        title: Text(
                          option,
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                        ),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
