import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';
import 'package:testrunflutter/data/models/UserModel.dart';
import 'package:testrunflutter/features/Pages/home/screens/detail_barber.dart';

class SearchShopField extends StatefulWidget {
  final double lat;
  final double lon;
  final UserModel userModel;

  const SearchShopField({
    super.key,
    required this.lat,
    required this.lon,
    required this.userModel,
  });

  @override
  State<SearchShopField> createState() => _SearchShopFieldState();
}

class _SearchShopFieldState extends State<SearchShopField> {
  final TextEditingController _controller = TextEditingController();
  String keyword = "";
  FireStoreDatabase dtb = FireStoreDatabase();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ô nhập từ khóa
        TextField(
          controller: _controller,
          style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
          decoration: InputDecoration(
            hintText: "Tìm quán cắt tóc...",
            prefixIcon: const Icon(Icons.search, color: Color(0XFF363062)),
            filled: true,
            fillColor: const Color(0xFFEBF0F5),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            setState(() {
              keyword = value.trim();
            });
          },
        ),
        const SizedBox(height: 10),

        // Khi có keyword thì show stream
        if (keyword.isNotEmpty)
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Shops")
                  .snapshots(), // lấy tất cả shops
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // lọc ở client (không phân biệt hoa/thường)
                final docs = snapshot.data!.docs.where((doc) {
                  final name = doc['shopName'].toString().toLowerCase();
                  return name.contains(keyword.toLowerCase());
                }).toList();

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Không tìm thấy",
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final shopModel = ShopModel.fromJson(docs[index].data());

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0XFF363062).withOpacity(0.1),
                        backgroundImage: NetworkImage(shopModel.shopAvatarImageUrl),
                      ),
                      title: Text(
                        shopModel.shopName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF111827),
                        ),
                      ),
                      subtitle: Text(
                        shopModel.location.address,
                        style: const TextStyle(color: Color(0xFF6B7280)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0XFF363062)),
                      onTap: () async {
                        final results = await Future.wait([
                          dtb.getDistance(widget.lat, widget.lon, shopModel),
                          getRate(shopModel.id),
                        ]);
                        final double km = results[0] as double;
                        final String rate = results[1] as String;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailBarber(
                              shop: shopModel,
                              km: km,
                              rate: rate,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          )
      ],
    );
  }

  Future<String> getRate(String idShop) async {
    final docRef = FirebaseFirestore.instance.collection('RatingShops').doc(idShop);
    final docSnapshot = await docRef.get();
    final data = docSnapshot.data();
    final quantity = data?['quantity'] ?? 0;
    final rating = data?['rating'] ?? 0.0;
    return '${double.parse(rating.toString())} ($quantity)';
  }
}
