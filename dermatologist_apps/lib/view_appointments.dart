import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

class DermatologistViewAppointments extends StatefulWidget {
  const DermatologistViewAppointments({super.key});

  @override
  State<DermatologistViewAppointments> createState() =>
      _DermatologistViewAppointmentsState();
}

class _DermatologistViewAppointmentsState
    extends State<DermatologistViewAppointments> {
  List appointments = [];
  bool loading = true;
  final Color bgBlack = const Color(0xFF0B0B0B);
  final Color darkCard = const Color(0xFF1A1A1A);
  final Color gold = const Color(0xFFC59A6D);
  final Color copper = const Color(0xFF7A4E2D);

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  /// FETCH APPOINTMENTS
  Future<void> fetchAppointments() async {
    try {
      final doctor = supabase.auth.currentUser;

      final response = await supabase
          .from('tbl_appointment')
          .select('''
        appointment_id,
        appointment_date,
        appointment_time,
        appointment_status,
        tbl_user(
          user_name,
          user_photo
        )
        ''')
          .eq('dermatologist_id', doctor!.id)
          .order('appointment_date');

      setState(() {
        appointments = response;
        loading = false;
      });
    } catch (e) {
      print("Error fetching appointments: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load appointments")),
      );

      setState(() {
        loading = false;
      });
    }
  }

  /// UPDATE STATUS
 Future<void> updateStatus(int id, String status) async {

 try {
    await supabase
      .from('tbl_appointment')
      .update({'appointment_status': status})
      .eq('appointment_id', id);

  fetchAppointments();
 } catch (e) {
    print("Error updating status: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to update appointment status")),
    );
   
 }
}
  /// APPOINTMENT CARD
  Widget appointmentCard(Map data) {
    final user = data['tbl_user'];
    final status = data['appointment_status'];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: gold.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gold.withOpacity(0.05), Colors.transparent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: gold, width: 2),
                      image: DecorationImage(
                        image: NetworkImage(user['user_photo'] ?? "https://via.placeholder.com/150"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['user_name'],
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Patient ID: #USR-${data['appointment_id']}",
                          style: GoogleFonts.outfit(color: gold.withOpacity(0.6), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(status),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildInfoIcon(Icons.calendar_today_rounded, data['appointment_date'].toString().split(' ')[0]),
                      const Spacer(),
                      _buildInfoIcon(Icons.access_time_rounded, data['appointment_time']),
                    ],
                  ),
                  if (status == "pending") ...[
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => updateStatus(data['appointment_id'], "rejected"),
                            child: const Text("REJECT", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: gold,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => updateStatus(data['appointment_id'], "accepted"),
                            child: const Text("ACCEPT", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = Colors.orange;
    if (status == "accepted") color = Colors.greenAccent;
    if (status == "rejected") color = Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.outfit(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }

  Widget _buildInfoIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: gold.withOpacity(0.5), size: 16),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: bgBlack,
      appBar: AppBar(
        backgroundColor: bgBlack,
        elevation: 0,
        title: Text(
          "Clinical Schedule",
          style: GoogleFonts.outfit(color: gold, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: fetchAppointments, icon: Icon(Icons.refresh_rounded, color: gold)),
        ],
      ),
      body: appointments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy_rounded, size: 80, color: gold.withOpacity(0.1)),
                  const SizedBox(height: 20),
                  Text(
                    "No pending appointments",
                    style: GoogleFonts.outfit(color: Colors.white24, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                return appointmentCard(appointments[index]);
              },
            ),
    );
  }
}
