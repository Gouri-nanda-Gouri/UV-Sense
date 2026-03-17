import 'package:admin_apps/sidebar_wrapper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:admin_apps/main.dart';
import 'package:admin_apps/api_monitoring.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final Color bgBlack = const Color(0xFF0B0B0B);
  final Color gold = const Color(0xFFC59A6D);
  final Color darkCard = const Color(0xFF1A1A1A);

  int userCount = 0;
  int doctorCount = 0;
  int productCount = 0;
  int orderCount = 0;
  double avgUv = 0.0;
  List uvData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
    _fetchGlobalUv();
  }

  Future<void> _fetchStats() async {
    try {
      final userRes = await supabase.from('tbl_user').select('user_id');
      final doctorRes = await supabase
          .from('tbl_dermatologist')
          .select('dermatologist_id');
      final productRes = await supabase
          .from('tbl_product')
          .select('product_id');
      final orderRes = await supabase
          .from('tbl_booking')
          .select('id')
          .neq('booking_status', 0);

      setState(() {
        userCount = userRes.length;
        doctorCount = doctorRes.length;
        productCount = productRes.length;
        orderCount = orderRes.length;
      });
    } catch (e) {
      debugPrint("Stats error: $e");
    }
  }

  String currentTemp = "--";
  String weatherDesc = "Loading...";

  Future<void> _fetchGlobalUv() async {
    try {
      // Local Weather (Kochi)
      final localRes = await http.get(
        Uri.parse('https://wttr.in/Kochi?format=j1'),
      );
      if (localRes.statusCode == 200) {
        final data = json.decode(localRes.body);
        setState(() {
          currentTemp = data['current_condition'][0]['temp_C'];
          weatherDesc = data['current_condition'][0]['weatherDesc'][0]['value'];
          avgUv = double.tryParse(data['current_condition'][0]['uvIndex']) ?? 0;
        });
      }

      // Trend Chart
      List<String> cities = [
        "Kochi",
        "Bangalore",
        "Mumbai",
        "Dubai",
        "Singapore",
      ];
      List<FlSpot> spots = [];
      for (int i = 0; i < cities.length; i++) {
        final res = await http.get(
          Uri.parse('https://wttr.in/${cities[i]}?format=j1'),
        );
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          double uv =
              double.tryParse(data['current_condition'][0]['uvIndex']) ?? 0;
          spots.add(FlSpot(i.toDouble(), uv));
        }
      }
      setState(() {
        uvData = spots;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("UV error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return SidebarWrapper(
        title: "Dashboard",
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: gold),
              const SizedBox(height: 15),
              Text(
                "Powering up UV Sense Engine...",
                style: GoogleFonts.outfit(
                  color: gold.withOpacity(0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );

    return SidebarWrapper(
      title: "Dashboard",
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() => isLoading = true);
          await _fetchStats();
          await _fetchGlobalUv();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildSoftStatCard(
                      "Total Users",
                      userCount.toString(),
                      "+3%",
                      Icons.people,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildSoftStatCard(
                      "Dermatologists",
                      doctorCount.toString(),
                      "+12%",
                      Icons.medical_services,
                      Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildSoftStatCard(
                      "Active Products",
                      productCount.toString(),
                      "+5%",
                      Icons.inventory_2,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildSoftStatCard(
                      "Monthly Revenue",
                      "₹${(orderCount * 499)}",
                      "+1.5%",
                      Icons.payments,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // 2. Main Feature Row
              Row(
                children: [
                  Expanded(flex: 2, child: _buildWelcomeCard()),
                  const SizedBox(width: 25),
                  Expanded(flex: 1, child: _buildHighlightCard()),
                ],
              ),
              const SizedBox(height: 25),

              // 3. Charts Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _buildBarChartCard()),
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: _buildSalesOverviewCard()),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoftStatCard(
    String title,
    String value,
    String percentage,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white30,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      percentage,
                      style: GoogleFonts.outfit(
                        color: Colors.greenAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Built by AI Scientists",
                  style: GoogleFonts.outfit(
                    color: gold,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "UV Sense Engine",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Real-time tracking: $currentTemp°C | UV Index: ${avgUv.toInt()} ($weatherDesc). Protection metrics are up by 22% compared to last quarter.",
                  style: GoogleFonts.outfit(
                    color: Colors.white54,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const APIMonitoring(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    "View Detailed Reports",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gold.withOpacity(0.8), gold.withOpacity(0.2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(
                  Icons.rocket_launch_rounded,
                  color: Colors.black,
                  size: 80,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.1)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1A1A1A), const Color(0xFF141414)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Work with insights",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Wealth of skin safety metrics is an evolutionary recent positive-sum game. It is all about who takes the opportunity first.",
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const APIMonitoring(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Get Started"),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartCard() {
    return Container(
      height: 420,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2D3436), Color(0xFF000000)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: 5,
                          color: Colors.white,
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: 12,
                          color: gold,
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: 8,
                          color: Colors.white,
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 4,
                      barRods: [
                        BarChartRodData(
                          toY: 15,
                          color: gold,
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 5,
                      barRods: [
                        BarChartRodData(
                          toY: 10,
                          color: Colors.white,
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 6,
                      barRods: [
                        BarChartRodData(
                          toY: 18,
                          color: gold,
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            "Active Users",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "(+23%) than last week",
            style: GoogleFonts.outfit(color: Colors.white30, fontSize: 13),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniSummary(Icons.people, "Users", userCount.toString()),
              _buildMiniSummary(Icons.ads_click, "Clicks", "2.4M"),
              _buildMiniSummary(Icons.shopping_cart, "Sales", "₹43k"),
              _buildMiniSummary(Icons.build, "Items", productCount.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSummary(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: gold, size: 10),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(color: Colors.white30, fontSize: 10),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSalesOverviewCard() {
    return Container(
      height: 420,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sales overview",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.arrow_upward,
                        color: Colors.greenAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "4% more",
                        style: GoogleFonts.outfit(
                          color: Colors.greenAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        " in 2024",
                        style: GoogleFonts.outfit(
                          color: Colors.white30,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              DropdownButton<String>(
                value: '2024',
                dropdownColor: Colors.black,
                underline: Container(),
                items: ['2023', '2024']
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 186, 92, 5),
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {},
              ),
            ],
          ),
          const SizedBox(height: 40),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) =>
                      const FlLine(color: Colors.white10, strokeWidth: 1),
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 310),
                      FlSpot(2, 450),
                      FlSpot(4, 380),
                      FlSpot(6, 600),
                      FlSpot(8, 420),
                      FlSpot(10, 800),
                      FlSpot(12, 590),
                    ],
                    isCurved: true,
                    color: gold,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: gold.withOpacity(0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 100),
                      FlSpot(2, 300),
                      FlSpot(4, 250),
                      FlSpot(6, 400),
                      FlSpot(8, 300),
                      FlSpot(10, 500),
                      FlSpot(12, 400),
                    ],
                    isCurved: true,
                    color: Colors.blueAccent,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blueAccent.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
