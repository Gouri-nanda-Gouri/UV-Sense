import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:admin_apps/main.dart';
import 'package:admin_apps/admin_home.dart';
import 'package:admin_apps/district.dart';
import 'package:admin_apps/place.dart';
import 'package:admin_apps/level.dart';
import 'package:admin_apps/colour.dart';
import 'package:admin_apps/category.dart';
import 'package:admin_apps/skintype.dart';
import 'package:admin_apps/heatabsorption.dart';
import 'package:admin_apps/addproduct.dart';
import 'package:admin_apps/myproducts.dart';
import 'package:admin_apps/view_booking.dart';
import 'package:admin_apps/view_dermatologist.dart';
import 'package:admin_apps/view_users.dart';
import 'package:admin_apps/api_monitoring.dart';
import 'package:admin_apps/view_complaints.dart';

class SidebarWrapper extends StatefulWidget {
  final Widget child;
  final String title;

  const SidebarWrapper({super.key, required this.child, required this.title});

  @override
  State<SidebarWrapper> createState() => _SidebarWrapperState();
}

class _SidebarWrapperState extends State<SidebarWrapper> {
  static bool isExpanded = true;

  final Color bgBlack = const Color(0xFF0B0B0B);
  final Color darkCard = const Color(0xFF1A1A1A);
  final Color gold = const Color(0xFFC59A6D);
  final Color sidebarColor = const Color(0xFF151515);

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBlack,
      body: Row(
        children: [
          // 1. Soft UI Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isExpanded ? 280 : 90,
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: sidebarColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(5, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 30),
                _buildSidebarHeader(),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    children: [
                      _buildSidebarItem(
                        Icons.dashboard_rounded,
                        "Dashboard",
                        const AdminHome(),
                        Colors.blueAccent,
                      ),
                      _buildSidebarItem(
                        Icons.map_rounded,
                        "Districts",
                        const District(),
                        Colors.greenAccent,
                      ),
                      _buildSidebarItem(
                        Icons.location_city_rounded,
                        "Places",
                        const Place(),
                        Colors.orangeAccent,
                      ),
                      _buildSidebarItem(
                        Icons.warning_amber_rounded,
                        "UV Levels",
                        const Level(),
                        Colors.redAccent,
                      ),
                      _buildSidebarItem(
                        Icons.palette_rounded,
                        "Colors",
                        const Colour(),
                        Colors.purpleAccent,
                      ),
                      _buildSidebarItem(
                        Icons.category_rounded,
                        "Categories",
                        const Category(),
                        Colors.tealAccent,
                      ),
                      _buildSidebarItem(
                        Icons.face_rounded,
                        "Skin Types",
                        const SkinType(),
                        Colors.pinkAccent,
                      ),
                      _buildSidebarItem(
                        Icons.water_drop_rounded,
                        "Heat Absorption",
                        const Heatabsorption(),
                        Colors.indigoAccent,
                      ),
                      _buildSidebarItem(
                        Icons.settings_input_component_rounded,
                        "API Engine",
                        const APIMonitoring(),
                        Colors.orangeAccent,
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 15,
                        ),
                        child: Text(
                          "ACCOUNT PAGES",
                          style: TextStyle(
                            color: Colors.white24,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      _buildSidebarItem(
                        Icons.add_business_rounded,
                        "Add Product",
                        const AddProduct(),
                        gold,
                      ),
                      _buildSidebarItem(
                        Icons.inventory_2_rounded,
                        "My Products",
                        const MyProducts(),
                        gold,
                      ),
                      _buildSidebarItem(
                        Icons.shopping_bag_rounded,
                        "Orders",
                        const AdminViewBooking(),
                        gold,
                      ),
                      _buildSidebarItem(
                        Icons.medical_services_rounded,
                        "Dermatologists",
                        const AdminViewDermatologist(),
                        gold,
                      ),
                      _buildSidebarItem(
                        Icons.people_alt_rounded,
                        "Users",
                        const AdminViewUsers(),
                        gold,
                      ),
                      _buildSidebarItem(
                        Icons.chat_bubble_rounded,
                        "Complaints",
                        const ViewComplaints(),
                        gold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Main Content
          Expanded(
            child: Column(
              children: [
                _buildSoftTopBar(),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                    ),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: isExpanded
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.shield_rounded, color: gold, size: 24),
                ),
                const SizedBox(width: 15),
                Text(
                  "UV SENSE",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            )
          : Icon(Icons.shield_rounded, color: gold, size: 30),
    );
  }

  Widget _buildSidebarItem(
    IconData icon,
    String title,
    Widget page,
    Color accent,
  ) {
    bool isSelected = widget.title == title;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: () {
          if (isSelected) return;
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => page,
              transitionDuration: Duration.zero,
            ),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? accent : Colors.white10,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [BoxShadow(color: accent.withOpacity(0.3), blurRadius: 8)]
                : [],
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white60,
            size: 18,
          ),
        ),
        title: isExpanded
            ? Text(
                title,
                style: GoogleFonts.outfit(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              )
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        minLeadingWidth: 0,
      ),
    );
  }

  Widget _buildCollapseToggle() {
    return IconButton(
      icon: Icon(
        isExpanded
            ? Icons.keyboard_double_arrow_left_rounded
            : Icons.keyboard_double_arrow_right_rounded,
        color: Colors.white24,
        size: 20,
      ),
      onPressed: () => setState(() => isExpanded = !isExpanded),
    );
  }

  Widget _buildSoftTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Pages",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const Text(
                    "  /  ",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  Text(
                    widget.title,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                widget.title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 250,
            height: 40,
            decoration: BoxDecoration(
              color: sidebarColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: const TextField(
              style: TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: "Type here...",
                hintStyle: TextStyle(color: Colors.white24),
                prefixIcon: Icon(Icons.search, color: Colors.white24, size: 18),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 20),
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: darkCard,
                  title: Text("Logout", style: GoogleFonts.outfit(color: gold)),
                  content: const Text(
                    "Are you sure you want to logout?",
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        await supabase.auth.signOut();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      child: Text(
                        "Logout",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.redAccent,
              size: 18,
            ),
            label: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 20),
          const Icon(Icons.settings, color: Colors.white54, size: 18),
        ],
      ),
    );
  }
}
