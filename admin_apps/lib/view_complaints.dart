import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:admin_apps/main.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewComplaints extends StatefulWidget {
  const ViewComplaints({super.key});

  @override
  State<ViewComplaints> createState() => _ViewComplaintsState();
}

class _ViewComplaintsState extends State<ViewComplaints> {
  final Color bgBlack = const Color(0xFF0B0B0B);
  final Color gold = const Color(0xFFC59A6D);
  final Color darkCard = const Color(0xFF1A1A1A);

  List complaints = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    try {
      final response = await supabase
          .from('tbl_complaint')
          .select('*, tbl_user(user_name, user_photo)')
          .order('id', ascending: false);
      setState(() {
        complaints = response;
        loading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => loading = false);
    }
  }

  Future<void> updateReply(int id, String reply) async {
    await supabase.from('tbl_complaint').update({
      'complaint_reply': reply,
      'complaint_status': 1,
    }).eq('complaint_id', id);
    fetchComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBlack,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final item = complaints[index];
                final user = item['tbl_user'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: darkCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: gold.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(user?['user_photo'] ?? ""),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user?['user_name'] ?? "Unknown", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(item['complaint_date'] ?? "", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(item['complaint_title'] ?? "", style: GoogleFonts.outfit(color: gold, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(item['complaint_content'] ?? "", style: GoogleFonts.outfit(color: Colors.white70)),
                      const Divider(color: Colors.white10, height: 30),
                      if (item['complaint_status'] == 0)
                        ElevatedButton(
                          onPressed: () => _showReplyDialog(item['id']),
                          style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black),
                          child: const Text("Reply"),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Reply:", style: GoogleFonts.outfit(color: gold, fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(item['complaint_reply'] ?? "", style: GoogleFonts.outfit(color: Colors.greenAccent)),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showReplyDialog(int id) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: darkCard,
        title: Text("Send Reply", style: GoogleFonts.outfit(color: gold)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: "Enter reply", hintStyle: TextStyle(color: Colors.white24)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              updateReply(id, controller.text);
              Navigator.pop(context);
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }
}
