import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:testrunflutter/features/Pages/home/screens/FindABarber.dart';

class MapCard extends StatefulWidget {
  final TextEditingController searchController;
  final bool isDisplay;
  final double height;

  const MapCard({
    super.key,
    required this.isDisplay,
    required this.height,
    required this.searchController,
  });

  @override
  State<MapCard> createState() => _MapCardState();
}

class _MapCardState extends State<MapCard> {
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    Position position = await Geolocator.getCurrentPosition();

    if (!mounted) return;

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: SizedBox(
            height: widget.height.h,
            child: Stack(
              children: [
                _currentPosition == null
                    ? const Center(child: CircularProgressIndicator())
                    : FlutterMap(
                        options: MapOptions(
                          initialCenter: _currentPosition!, // lấy tâm bản đồ là vị trí hiện tại
                          initialZoom: 16, // mứcddooj phóng to thu nhỏ
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', //đường dẫn tải tile từ CartoDB, dùng bản đồ sáng.
                            subdomains: ['a', 'b', 'c'],
                            userAgentPackageName: 'com.example.testrunflutter',
                            retinaMode: RetinaMode.isHighDensity(context),
                          ),


                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _currentPosition!,
                                child: const Icon(
                                  Icons.location_pin,
                                  size: 40,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                if (widget.isDisplay)
                  Positioned(
                    bottom: 12.h,
                    right: 12.w,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF363062),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const FindABarber(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  final tween = Tween(
                                    begin: const Offset(1.0, 0.0),
                                    end: Offset.zero,
                                  );
                                  final curved = CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.ease,
                                  );
                                  return SlideTransition(
                                    position: tween.animate(curved),
                                    child: child,
                                  );
                                },
                            transitionDuration: const Duration(
                              milliseconds: 1000,
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                      label: const Text(
                        'Find now',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                else
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    right: 12.w,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: widget.searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm địa điểm...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade600,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
