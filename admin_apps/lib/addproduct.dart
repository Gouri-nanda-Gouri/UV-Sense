import 'dart:typed_data';
import 'package:admin_apps/sidebar_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:google_fonts/google_fonts.dart';
import 'package:admin_apps/main.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  Uint8List? imageBytes;
  file_picker.PlatformFile? pickedImage;

  final Color darkCard = const Color(0xFF1A1A1A);
  final Color gold = const Color(0xFFC59A6D);

  List categoryList = [];
  List skinTypeList = [];
  List levelList = [];
  List heatList = [];
  int? selectedSkinType;
  int? selectedCategoryId;
  int? selectedLevelId;
  int? selectedHeatId;
  bool isSubmitting = false;
  bool isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    try {
      final catRes = await supabase.from('tbl_category').select().order('category_name');
      final skinRes = await supabase.from('tbl_skintype').select().order('skintype_name');
      final levelRes = await supabase.from('tbl_level').select().order('level_name');
      final heatRes = await supabase.from('tbl_heatabsorption').select().order('heatabsorption_name');
      setState(() {
        categoryList = catRes;
        skinTypeList = skinRes;
        levelList = levelRes;
        heatList = heatRes;
        isInitialLoading = false;
      });
    } catch (e) {
      debugPrint("Fetch Error: $e");
      setState(() => isInitialLoading = false);
    }
  }

  Future<void> pickImage() async {
    try {
      file_picker.FilePickerResult? result = await file_picker.FilePicker.platform.pickFiles(
        type: file_picker.FileType.image, 
        withData: true
      );
      if (result == null) return;
      setState(() {
        pickedImage = result.files.first;
        imageBytes = pickedImage!.bytes;
      });
    } catch (e) {
      debugPrint("Picker Error: $e");
    }
  }

  Future<void> insertProduct() async {
    final name = nameController.text.trim();
    final priceStr = priceController.text.trim();
    final double? price = double.tryParse(priceStr);

    if (name.isEmpty || selectedCategoryId == null || selectedSkinType == null || price == null || imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields accurately and upload an image"), behavior: SnackBarBehavior.floating)
      );
      return;
    }

    setState(() => isSubmitting = true);
    try {
      final String extension = pickedImage?.extension ?? 'jpg';
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.$extension";
      
      await supabase.storage.from('product_images').uploadBinary(fileName, imageBytes!);
      final imageUrl = supabase.storage.from('product_images').getPublicUrl(fileName);

      await supabase.from('tbl_product').insert({
        'product_name': name,
        'product_description': descriptionController.text.trim(),
        'skin_type': selectedSkinType,
        'category_id': selectedCategoryId,
        'level_id': selectedLevelId,
        'heat_id': selectedHeatId,
        'price': price,
        'photo': imageUrl,
        'stock': 0,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product Launched Successfully")));
      }
    } catch (e) {
      debugPrint("Insert Error: $e");
      if (mounted) {
        setState(() => isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isInitialLoading) {
      return const SidebarWrapper(title: "Loading...", child: Center(child: CircularProgressIndicator()));
    }

    return SidebarWrapper(
      title: "Inventory Creation",
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(50),
          child: Column(
            children: [
              Text("Create Premium Product", style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Define detailed metrics for the new inventory item", style: const TextStyle(color: Colors.white30, fontSize: 14)),
              const SizedBox(height: 40),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Left: Visual Asset
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        height: 450,
                        decoration: BoxDecoration(
                          color: darkCard,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: gold.withOpacity(0.2)),
                        ),
                        child: imageBytes != null
                            ? ClipRRect(borderRadius: BorderRadius.circular(30), child: Image.memory(imageBytes!, fit: BoxFit.cover))
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_rounded, color: gold, size: 50),
                                  const SizedBox(height: 15),
                                  Text("Upload Product Image", style: TextStyle(color: gold.withOpacity(0.5))),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  
                  /// Right: Data Form
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(0.05))),
                      child: Column(
                        children: [
                          _buildField(nameController, "Product Title", Icons.label_outline_rounded),
                          const SizedBox(height: 20),
                          _buildField(descriptionController, "Detailed Description...", Icons.notes_rounded, maxLines: 4),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown("Select Category", selectedCategoryId, categoryList, (v) => setState(() => selectedCategoryId = v), 'category_id', 'category_name'),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildDropdown("Skin Target", selectedSkinType, skinTypeList, (v) => setState(() => selectedSkinType = v), 'type_id', 'skintype_name'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown("UV Intensity", selectedLevelId, levelList, (v) => setState(() => selectedLevelId = v), 'level_id', 'level_name'),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildDropdown("Heat Profile", selectedHeatId, heatList, (v) => setState(() => selectedHeatId = v), 'heatabsorption_id', 'heatabsorption_name'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildField(priceController, "Retail Price (INR)", Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: isSubmitting ? null : insertProduct,
                              style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                              child: isSubmitting 
                                ? const CircularProgressIndicator(color: Colors.black)
                                : Text("LAUNCH PRODUCT", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
        prefixIcon: Icon(icon, color: gold.withOpacity(0.5), size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.02),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown(String label, int? value, List items, Function(int?) onChanged, String idKey, String nameKey) {
    // 1. Process items and filter out any that don't have a valid ID
    final List<Map<String, dynamic>> validItems = [];
    final Set<int> seenIds = {};

    for (var item in items) {
      int? id = item[idKey] is int ? item[idKey] : int.tryParse(item[idKey]?.toString() ?? "");
      if (id != null && !seenIds.contains(id)) {
        validItems.add({
          'id': id,
          'name': item[nameKey]?.toString() ?? "Untitled",
        });
        seenIds.add(id);
      }
    }

    // 2. Ensure initial value is actually in our valid list
    int? safeValue = (value != null && seenIds.contains(value)) ? value : null;

    return DropdownButtonFormField<int>(
      value: safeValue,
      dropdownColor: darkCard,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      items: validItems.map((item) {
        return DropdownMenuItem<int>(
          value: item['id'] as int,
          child: Text(item['name'] as String),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.02),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}
