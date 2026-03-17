import 'package:flutter/material.dart';
import 'main.dart';

class VerifyDermatologistPage extends StatelessWidget {

  final Map data;

  const VerifyDermatologistPage({super.key, required this.data});

  Future<void> updateStatus(BuildContext context, String status) async {

    await supabase
        .from('tbl_dermatologist')
        .update({'dermatologist_status': status})
        .eq('dermatologist_id', data['dermatologist_id']);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),

      appBar: AppBar(
        title: const Text("Verify Dermatologist"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// PROFILE
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    NetworkImage(data['dermatologist_photo']),
              ),
            ),

            const SizedBox(height: 20),

            /// NAME
            Text(
              "Name: ${data['dermatologist_name']}",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),

            const SizedBox(height: 10),

            /// EMAIL
            Text(
              "Email: ${data['dermatologist_email']}",
              style: const TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 10),

            /// CONTACT
            Text(
              "Contact: ${data['dermatologist_contact']}",
              style: const TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 25),

            const Text(
              "Medical Certificate",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            /// CERTIFICATE IMAGE
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    child: InteractiveViewer(
                      child: Image.network(
                        data['dermatologist_certificate'],
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    data['dermatologist_certificate'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            /// ACTION BUTTONS
            Row(
              children: [

                /// ACCEPT
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      updateStatus(context, "accepted");
                    },
                    child: const Text("Approve"),
                  ),
                ),

                const SizedBox(width: 15),

                /// REJECT
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      updateStatus(context, "rejected");
                    },
                    child: const Text("Reject"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}