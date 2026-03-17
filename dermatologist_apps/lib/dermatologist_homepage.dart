import 'package:dermatologist_apps/view_appointments.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'dermatologist_myprofile.dart';
import 'package:google_fonts/google_fonts.dart';

class DermatologistHome extends StatefulWidget {
  const DermatologistHome({super.key});

  @override
  State<DermatologistHome> createState() => _DermatologistHomeState();
}

class _DermatologistHomeState extends State<DermatologistHome> {
  static const Color gold = Color(0xFFC59A6D);
  static const Color glass = Color(0xFF1F1F1F);
  static const Color bgBlack = Color(0xFF0B0B0B);

  Map? profile;
  List appointments = [];
  int totalCount = 0;
  int pendingCount = 0;
  int acceptedCount = 0;
  bool loading = true;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final doctor = supabase.auth.currentUser;
      if (doctor == null) return;

      final profileData = await supabase
          .from('tbl_dermatologist')
          .select()
          .eq('dermatologist_id', doctor.id)
          .single();

      final appointmentData = await supabase
          .from('tbl_appointment')
          .select('''
            *,
            tbl_user(user_name, user_photo)
          ''')
          .eq('dermatologist_id', doctor.id)
          .order('id', ascending: false);

      int total = appointmentData.length;
      int pending = appointmentData
          .where((e) => e['appointment_status'] == "pending")
          .length;
      int accepted = appointmentData
          .where((e) => e['appointment_status'] == "accepted")
          .length;

      setState(() {
        profile = profileData;
        appointments = List.from(appointmentData);
        totalCount = total;
        pendingCount = pending;
        acceptedCount = accepted;
        loading = false;
      });
    } catch (e) {
      debugPrint("Fetch Data Error: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: bgBlack,
        body: Center(child: CircularProgressIndicator(color: gold)),
      );
    }

    final pages = [
      _buildDashboard(),
      const DermatologistViewAppointments(),
      const DermatologistMyProfile(),
    ];

    return Scaffold(
      backgroundColor: bgBlack,
      body: pages[currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDashboard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            bgBlack,
            const Color(0xFF141414),
            const Color(0xFF2B1A0F).withOpacity(0.2),
            bgBlack,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchData,
          color: gold,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                _buildHeader(),
                const SizedBox(height: 35),
                _buildStatCards(),
                const SizedBox(height: 40),
                Text(
                  "Recent Consultations",
                  style: GoogleFonts.outfit(
                    color: gold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildAppointmentsList(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome back,",
              style: GoogleFonts.outfit(color: Colors.white54, fontSize: 16),
            ),
            Text(
              "Dr. ${profile?['dermatologist_name'] ?? 'Doctor'}",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 28,
          backgroundColor: gold,
          child: CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(
              profile?['dermatologist_photo'] ?? "",
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(
          "Total",
          totalCount.toString(),
          Icons.calendar_today,
          Colors.blue,
        ),
        _buildStatCard(
          "Pending",
          pendingCount.toString(),
          Icons.pending_actions,
          Colors.orange,
        ),
        _buildStatCard(
          "Done",
          acceptedCount.toString(),
          Icons.check_circle_outline,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color accent,
  ) {
    return Container(
      width: (MediaQuery.of(context).size.width - 70) / 3,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: glass,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: gold.withOpacity(.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: accent, size: 24),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    if (appointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Text(
            "No appointments yet.",
            style: GoogleFonts.outfit(color: Colors.white24),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appointments.length > 5 ? 5 : appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        final apt = appointments[index];
        final user = apt['tbl_user'];
        final status = apt['appointment_status'];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: glass,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white10,
                backgroundImage: NetworkImage(user?['user_photo'] ?? ""),
                child: user?['user_photo'] == null
                    ? const Icon(Icons.person, color: Colors.white24)
                    : null,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?['user_name'] ?? 'Unknown User',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "${apt['appointment_date']} • ${apt['appointment_time']}",
                      style: GoogleFonts.outfit(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: _getStatusColor(status),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, top: 10),
      decoration: BoxDecoration(
        color: glass,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: gold,
        unselectedItemColor: Colors.white30,
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: "Board",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: "Visits",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_outlined),
            activeIcon: Icon(Icons.person_pin),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
