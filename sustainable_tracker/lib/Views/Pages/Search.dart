// lib/Views/search/search_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sustainable_tracker/Views/widgets/Productinfo.dart'
    as productInfo;

class searchPage extends StatefulWidget {
  final String? initialCategory;
  const searchPage({super.key, this.initialCategory});

  @override
  State<searchPage> createState() => _searchPageState();
}

class _searchPageState extends State<searchPage> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filtered = [];
  bool loading = true;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    products = List<Map<String, dynamic>>.from(productInfo.products);

    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      final cat = widget.initialCategory!.toLowerCase();
      filtered = products.where((p) {
        final pc = (p['category'] ?? '').toString().toLowerCase();
        return pc == cat;
      }).toList();
      // optional: show category text in search box
      searchController.text = widget.initialCategory!;
    } else {
      filtered = products;
    }

    setState(() => loading = false);
  }

  void search(String query) {
    final q = query.toLowerCase();
    setState(() {
      filtered = products.where((item) {
        final name = item["productName"].toString().toLowerCase();
        final brand = item["brandName"].toString().toLowerCase();
        final category = item["category"].toString().toLowerCase();
        return name.contains(q) || brand.contains(q) || category.contains(q);
      }).toList();
    });
  }

  Widget _buildImage(String url) {
    if (url == null || url.isEmpty) {
      return Container(width: 100, height: 100, color: Colors.grey[300]);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        url,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Container(width: 100, height: 100, color: Colors.grey[300]),
      ),
    );
  }

  Future<void> openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not open URL: $url");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 60,
        title: const Text(
          "Search",
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 244, 242, 242),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: searchController,
                onChanged: search,
                decoration: const InputDecoration(
                  hintText: "Search products...",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 10),
                ),
              ),
            ),
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : filtered.isEmpty
          ? const Center(
              child: Text('No products found', style: TextStyle(fontSize: 16)),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                final name = item["productName"] ?? 'Unknown';
                final brand = item["brandName"] ?? 'Unknown';
                final image = item["image"] ?? '';
                final price = item["price"] ?? 0;
                final rating = (item["rating"] ?? 0).toDouble();
                final carbon = (item["productCarbonWeight"] ?? 0).toDouble();

                String impactText;
                Color impactColor;
                if (carbon <= 5) {
                  impactText = "Low Impact";
                  impactColor = Colors.green;
                } else if (carbon <= 8) {
                  impactText = "Medium Impact";
                  impactColor = Colors.orange;
                } else {
                  impactText = "High Impact";
                  impactColor = Colors.red;
                }

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildImage(image),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      softWrap: true,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          brand,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(
                                          Icons.star,
                                          size: 16,
                                          color: Color.fromARGB(
                                            255,
                                            239,
                                            185,
                                            7,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          rating.toStringAsFixed(1),
                                          style: const TextStyle(
                                            color: Color.fromARGB(
                                              255,
                                              239,
                                              185,
                                              7,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '₹$price',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text(
                                'Carbon FootPrint:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '🔴 ${carbon.toStringAsFixed(2)} kg CO₂',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: impactColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    impactText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 45,
                              vertical: 10,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () =>
                                    openUrl(item["productUrl"] ?? ''),
                                child: const Text(
                                  'Buy Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
