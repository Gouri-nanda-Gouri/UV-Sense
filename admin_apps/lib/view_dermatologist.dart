import 'package:admin_apps/sidebar_wrapper.dart';
import 'package:admin_apps/verify_dermatologist_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

class AdminViewDermatologist extends StatefulWidget {
  const AdminViewDermatologist({super.key});

  @override
  State<AdminViewDermatologist> createState() => _AdminViewDermatologistState();
}

class _AdminViewDermatologistState extends State<AdminViewDermatologist>
    with TickerProviderStateMixin {

  late TabController tabController;

  List dermatologists = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    fetchDermatologists();
  }

  /// FETCH DATA
  Future<void> fetchDermatologists() async {
    final response = await supabase.from('tbl_dermatologist').select();

    setState(() {
      dermatologists = response;
      loading = false;
    });
  }

  /// UPDATE STATUS
  Future<void> updateStatus(String id, String status) async {
    await supabase
        .from('tbl_dermatologist')
        .update({'dermatologist_status': status})
        .eq('dermatologist_id', id);

    fetchDermatologists();
  }

  /// FILTER DATA
  List filterData(String status) {
    return dermatologists
        .where((e) => e['dermatologist_status'] == status)
        .toList();
  }

  /// CARD UI
  Widget buildCard(Map data, {bool showButtons = false}) {

    String photo = data['dermatologist_photo'] ?? "";
    String certificate = data['dermatologist_certificate'] ?? "";

    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      child: ListTile(

        /// PHOTO
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey,
          backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
          child: photo.isEmpty
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        ),

        /// NAME
        title: Text(
          data['dermatologist_name'] ?? "",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        /// EMAIL
        subtitle: Text(
          data['dermatologist_email'] ?? "",
          style: const TextStyle(color: Colors.white70),
        ),

        /// ACCEPT / REJECT
        trailing: showButtons
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  /// ACCEPT
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () {
                      updateStatus(data['dermatologist_id'], "accepted");
                    },
                  ),

                  /// REJECT
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      updateStatus(data['dermatologist_id'], "rejected");
                    },
                  ),
                ],
              )
            : null,

        /// VIEW CERTIFICATE
        onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => VerifyDermatologistPage(data: data),
    ),
  ).then((_) => fetchDermatologists());
},
      ),
    );
  }

  /// LIST BUILDER
  Widget buildList(String status, {bool showButtons = false}) {

    List data = filterData(status);

    if (data.isEmpty) {
      return const Center(
        child: Text(
          "No Data Found",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return buildCard(data[index], showButtons: showButtons);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SidebarWrapper(
        title: "Dermatologists",
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SidebarWrapper(
      title: "Dermatologists",
      child: Column(
        children: [
          TabBar(
            controller: tabController,
            labelColor: const Color(0xFFC59A6D),
            unselectedLabelColor: Colors.white54,
            indicatorColor: const Color(0xFFC59A6D),
            tabs: const [
              Tab(text: "Pending"),
              Tab(text: "Accepted"),
              Tab(text: "Rejected"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                buildList("pending", showButtons: true),
                buildList("accepted"),
                buildList("rejected"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}