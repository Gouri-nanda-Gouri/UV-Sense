import 'package:admin_apps/sidebar_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';

class District extends StatefulWidget {
  const District({super.key});

  @override
  State<District> createState() => _DistrictState();
}

class _DistrictState extends State<District> {
  final TextEditingController districtController = TextEditingController();
  List districtList = [];
  bool isLoading = true;
  bool isFormVisible = false;
  int? editingId;

  final Color gold = const Color(0xFFC59A6D);
  final Color darkCard = const Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    fetchDistrict();
  }

  Future<void> fetchDistrict() async {
    try {
      final response = await supabase.from('tbl_district').select().order('district_id', ascending: false);
      setState(() {
        districtList = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Fetch error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> handleSubmit() async {
    final name = districtController.text.trim();
    if (name.isEmpty) return;

    if (editingId == null) {
      await supabase.from('tbl_district').insert({'district_name': name});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("District Added")));
    } else {
      await supabase.from('tbl_district').update({'district_name': name}).eq('district_id', editingId!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("District Updated")));
    }
    
    cancelForm();
    fetchDistrict();
  }

  void cancelForm() {
    setState(() {
      districtController.clear();
      isFormVisible = false;
      editingId = null;
    });
  }

  Future<void> delete(int id) async {
    await supabase.from('tbl_district').delete().eq('district_id', id);
    fetchDistrict();
  }

  void startEdit(int id, String name) {
    setState(() {
      districtController.text = name;
      editingId = id;
      isFormVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SidebarWrapper(
      title: "Districts",
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            /// Header
            Row(
              children: [
                Text("District Directory", style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (!isFormVisible)
                  ElevatedButton.icon(
                    onPressed: () => setState(() => isFormVisible = true),
                    icon: const Icon(Icons.add),
                    label: const Text("ADD NEW"),
                    style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            /// Animated Entry Form
            if (isFormVisible)
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: darkCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: gold.withOpacity(0.3)),
                  boxShadow: [BoxShadow(color: gold.withOpacity(0.1), blurRadius: 20)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(editingId == null ? "Add New District" : "Edit District", style: GoogleFonts.outfit(color: gold, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: districtController,
                            autofocus: true,
                            style: GoogleFonts.outfit(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Enter district name...",
                              hintStyle: const TextStyle(color: Colors.white30),
                              prefixIcon: Icon(Icons.map_rounded, color: gold, size: 20),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.02),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: handleSubmit,
                          style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: Text(editingId == null ? "SUBMIT" : "UPDATE", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: cancelForm,
                          child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            /// Data List
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: gold))
                  : districtList.isEmpty 
                    ? const Center(child: Text("No districts found.", style: TextStyle(color: Colors.white24)))
                    : ListView.builder(
                      itemCount: districtList.length,
                      itemBuilder: (context, index) {
                        final d = districtList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            color: darkCard,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white.withOpacity(0.03)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: gold.withOpacity(0.1), radius: 18,
                                child: Text("${index + 1}", style: TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 20),
                              Text(d['district_name'] ?? "", style: GoogleFonts.outfit(color: Colors.white, fontSize: 15)),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit_note_rounded, color: Colors.blueAccent),
                                onPressed: () => startEdit(d['district_id'], d['district_name']),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 20),
                                onPressed: () => delete(d['district_id']),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}