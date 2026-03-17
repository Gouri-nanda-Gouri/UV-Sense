import 'package:admin_apps/sidebar_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:admin_apps/main.dart';

class AddStock extends StatefulWidget {
  final int productId;
  const AddStock({super.key, required this.productId});

  @override
  State<AddStock> createState() => _AddStockState();
}

class _AddStockState extends State<AddStock> {
  final TextEditingController countController = TextEditingController();
  final Color darkCard = const Color(0xFF1A1A1A);
  final Color gold = const Color(0xFFC59A6D);
  bool isLoading = false;

  Future<void> updateStock() async {
    final countText = countController.text.trim();
    if (countText.isEmpty) return;

    setState(() => isLoading = true);
    try {
      int addedStock = int.parse(countText);
      
      // 1. Log the stock entry
      await supabase.from('tbl_stock').insert({
        'product_id': widget.productId,
        'stock_count': addedStock,
      });

      // 2. Update the aggregate stock in tbl_product
      final productRes = await supabase.from('tbl_product').select('stock').eq('product_id', widget.productId).single();
      int currentStock = productRes['stock'] ?? 0;
      
      await supabase.from('tbl_product').update({
        'stock': currentStock + addedStock
      }).eq('product_id', widget.productId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Stock Updated Successfully")));
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Stock Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SidebarWrapper(
      title: "Stock Management",
      child: Center(
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: darkCard,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 80, width: 80,
                decoration: BoxDecoration(color: gold.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.add_business_rounded, color: gold, size: 40),
              ),
              const SizedBox(height: 25),
              Text("Replenish Inventory", style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Enter the number of units to add to current stock", style: TextStyle(color: Colors.white30, fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 35),
              TextField(
                controller: countController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: gold, fontSize: 30, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: "00",
                  hintStyle: const TextStyle(color: Colors.white10),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.02),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateStock,
                  style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: isLoading 
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text("CONFIRM STOCK ADDITION", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Go Back", style: TextStyle(color: Colors.white24))),
            ],
          ),
        ),
      ),
    );
  }
}