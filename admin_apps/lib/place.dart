import 'package:admin_apps/sidebar_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';

class Place extends StatefulWidget {
  const Place({super.key});

  @override
  State<Place> createState() => _PlaceState();
}

class _PlaceState extends State<Place> {
  final TextEditingController placeController = TextEditingController();
  List districtList = [];
  List placeList = [];
  int? selectedDistrictId;
  int? editingId;
  bool isLoading = true;
  bool isFormVisible = false;

  final Color gold = const Color(0xFFC59A6D);
  final Color darkCard = const Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await fetchDistricts();
    await fetchPlaces();
    setState(() => isLoading = false);
  }

  Future<void> fetchDistricts() async {
    final res = await supabase.from('tbl_district').select().order('district_name');
    setState(() => districtList = res);
  }

  Future<void> fetchPlaces() async {
    final res = await supabase.from('tbl_place').select('*, tbl_district(district_name)').order('place_id', ascending: false);
    setState(() => placeList = res);
  }

  Future<void> handleSubmit() async {
    final name = placeController.text.trim();
    if (name.isEmpty || selectedDistrictId == null) return;

    if (editingId == null) {
      await supabase.from('tbl_place').insert({
        'place_name': name,
        'district_id': selectedDistrictId,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Place Added")));
    } else {
      await supabase.from('tbl_place').update({
        'place_name': name,
        'district_id': selectedDistrictId,
      }).eq('place_id', editingId!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Place Updated")));
    }
    
    cancelForm();
    fetchPlaces();
  }

  void cancelForm() {
    setState(() {
      placeController.clear();
      selectedDistrictId = null;
      editingId = null;
      isFormVisible = false;
    });
  }

  Future<void> delete(int id) async {
    await supabase.from('tbl_place').delete().eq('place_id', id);
    fetchPlaces();
  }

  void startEdit(Map p) {
    setState(() {
      placeController.text = p['place_name'];
      selectedDistrictId = p['district_id'];
      editingId = p['place_id'];
      isFormVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SidebarWrapper(
      title: "Places",
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            /// Header Row
            Row(
              children: [
                Text("Place Management", style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (!isFormVisible)
                  ElevatedButton.icon(
                    onPressed: () => setState(() => isFormVisible = true),
                    icon: const Icon(Icons.add_location_alt_rounded),
                    label: const Text("ADD NEW PLACE"),
                    style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            /// Editable Form Area
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
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: (selectedDistrictId != null && districtList.any((d) => d['district_id'] == selectedDistrictId)) 
                                    ? selectedDistrictId 
                                    : null,
                            dropdownColor: darkCard,
                            style: GoogleFonts.outfit(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Select District",
                              hintStyle: const TextStyle(color: Colors.white30),
                              prefixIcon: Icon(Icons.location_city_rounded, color: gold, size: 20),
                              filled: true, fillColor: Colors.white.withOpacity(0.02),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                            ),
                            items: districtList.map((d) {
                              int? id = d['district_id'] is int ? d['district_id'] : int.tryParse(d['district_id'].toString());
                              return DropdownMenuItem<int>(
                                value: id, 
                                child: Text(d['district_name']?.toString() ?? "Untitled")
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => selectedDistrictId = v),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextField(
                            controller: placeController,
                            style: GoogleFonts.outfit(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "New place name...",
                              hintStyle: const TextStyle(color: Colors.white30),
                              prefixIcon: Icon(Icons.map_rounded, color: gold, size: 20),
                              filled: true, fillColor: Colors.white.withOpacity(0.02),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: handleSubmit,
                          style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: Text(editingId == null ? "ADD PLACE" : "UPDATE PLACE", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        const SizedBox(width: 10),
                        TextButton(onPressed: cancelForm, child: const Text("CANCEL", style: TextStyle(color: Colors.white54))),
                      ],
                    ),
                  ],
                ),
              ),

            /// List Content
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: gold))
                  : placeList.isEmpty 
                    ? const Center(child: Text("No places defined yet.", style: TextStyle(color: Colors.white24)))
                    : ListView.builder(
                      itemCount: placeList.length,
                      itemBuilder: (context, index) {
                        final p = placeList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withOpacity(0.03))),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p['place_name'] ?? "", style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 5),
                                  Text(p['tbl_district']?['district_name'] ?? "Unknown District", style: const TextStyle(color: Colors.white38, fontSize: 11)),
                                ],
                              ),
                              const Spacer(),
                              IconButton(icon: const Icon(Icons.edit_note_rounded, color: Colors.blueAccent), onPressed: () => startEdit(p)),
                              IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20), onPressed: () => delete(p['place_id'])),
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