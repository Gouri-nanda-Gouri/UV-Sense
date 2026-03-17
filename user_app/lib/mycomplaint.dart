import 'package:flutter/material.dart';

class MyComplaint extends StatefulWidget {
  const MyComplaint({super.key});

  @override
  State<MyComplaint> createState() => _MyComplaintState();
}

class _MyComplaintState extends State<MyComplaint> {

  /// Luxury Colors
  final Color bgBlack = const Color(0xFF0B0B0B);
  final Color darkCard = const Color(0xFF1A1A1A);
  final Color gold = const Color(0xFFC59A6D);
  final Color copper = const Color(0xFF7A4E2D);
  final Color glass = const Color(0xFF262626);

  /// MOCK DATA
  List<Map<String, dynamic>> complaintList = [
    {
      "complaint_id": 1,
      "title": "Late Delivery",
      "content": "My order was delivered 3 days late.",
      "reply": "Refund issued",
    },
    {
      "complaint_id": 2,
      "title": "Damaged Product",
      "content": "Bottle was broken inside package.",
      "reply": "Replacement dispatched",
    },
    {
      "complaint_id": 3,
      "title": "Wrong Item",
      "content": "Received wrong product instead of serum.",
      "reply": "Under verification",
    },
  ];

  /// Delete Complaint
  void deleteComplaint(int id) {
    setState(() {
      complaintList.removeWhere(
        (complaint) => complaint['complaint_id'] == id,
      );
    });
  }

  /// Reply Badge Color
  Color getReplyColor(String reply) {
    if (reply.contains("Refund") || reply.contains("Replacement")) {
      return Colors.green;
    } else if (reply.contains("verification")) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        /// Luxury Background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              bgBlack,
              const Color(0xFF141414),
              copper.withOpacity(.4),
              const Color(0xFF141414),
              bgBlack,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),

            child: Container(

              constraints: const BoxConstraints(maxWidth: 1200),

              padding: const EdgeInsets.all(30),

              decoration: BoxDecoration(
                color: darkCard,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: gold.withOpacity(.5)),
                boxShadow: [

                  /// Gold Glow
                  BoxShadow(
                    color: gold.withOpacity(.25),
                    blurRadius: 40,
                  ),

                  /// Depth Shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(.7),
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),

              child: Column(

                children: [

                  /// Header Icon
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [gold, copper],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: gold.withOpacity(.6),
                          blurRadius: 35,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      color: Colors.black,
                      size: 35,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "My Complaints",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          gold,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  complaintList.isEmpty
                      ? const Text(
                          "No complaints available.",
                          style: TextStyle(color: Colors.white70),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(

                            columnSpacing: 40,

                            headingRowColor:
                                MaterialStateProperty.all(glass),

                            columns: const [

                              DataColumn(
                                label: Text(
                                  "SC No",
                                  style: TextStyle(
                                      color: Colors.white),
                                ),
                              ),

                              DataColumn(
                                label: Text(
                                  "Title",
                                  style: TextStyle(
                                      color: Colors.white),
                                ),
                              ),

                              DataColumn(
                                label: Text(
                                  "Content",
                                  style: TextStyle(
                                      color: Colors.white),
                                ),
                              ),

                              DataColumn(
                                label: Text(
                                  "Reply",
                                  style: TextStyle(
                                      color: Colors.white),
                                ),
                              ),

                              DataColumn(
                                label: Text(
                                  "Action",
                                  style: TextStyle(
                                      color: Colors.white),
                                ),
                              ),
                            ],

                            rows: List.generate(
                              complaintList.length,
                              (index) {

                                final complaint =
                                    complaintList[index];

                                return DataRow(

                                  cells: [

                                    DataCell(Text(
                                      "${index + 1}",
                                      style: const TextStyle(
                                          color: Colors.white),
                                    )),

                                    DataCell(Text(
                                      complaint['title'],
                                      style: const TextStyle(
                                          color: Colors.white),
                                    )),

                                    DataCell(
                                      SizedBox(
                                        width: 250,
                                        child: Text(
                                          complaint['content'],
                                          style: const TextStyle(
                                              color: Colors.white70),
                                          overflow:
                                              TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),

                                    /// Reply Badge
                                    DataCell(
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6),
                                        decoration: BoxDecoration(
                                          color: getReplyColor(
                                                  complaint['reply'])
                                              .withOpacity(.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          complaint['reply'],
                                          style: TextStyle(
                                            color: getReplyColor(
                                                complaint['reply']),
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// Delete Button
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          deleteComplaint(
                                              complaint[
                                                  'complaint_id']);
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}