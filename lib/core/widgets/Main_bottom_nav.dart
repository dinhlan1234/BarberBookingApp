import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testrunflutter/features/Pages/booking/screens/BookingPage.dart';
import 'package:testrunflutter/features/Pages/chat/screens/ChatPage.dart';
import 'package:testrunflutter/features/Pages/home/screens/HomePage.dart';
import 'package:testrunflutter/features/Pages/profile/screens/ProfilePage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/widgets.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}


class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Sử dụng final để tránh rebuild pages
  static const List<Widget> _pages = [
    HomePage(),
    BookingPage(),
    ChatPage(),
    ProfilePage(),
  ];

  void _onTab(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // IndexedStack giữ state và không rebuild các page khác
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: CupertinoTabBar(
          activeColor: const Color(0xFF363062),
          inactiveColor: Colors.grey.shade400,
          currentIndex: _selectedIndex,
          onTap: _onTab,
          backgroundColor: Colors.transparent,
          items: [
            _buildOptimizedTab(
              iconPath: 'assets/icons/home.png',
              label: "Trang chủ",
              index: 0,
            ),
            _buildOptimizedTab(
              iconPath: 'assets/icons/Calendar Mark.png',
              label: "Lịch trình",
              index: 1,
            ),
            _buildOptimizedTab(
              iconPath: 'assets/icons/Chat Round Unread.png',
              label: "Chat",
              index: 2,
            ),
            _buildOptimizedTab(
              iconPath: 'assets/icons/profile.png',
              label: "Bạn",
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildOptimizedTab({
    required String iconPath,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;

    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 38.w,
        height: 38.h,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF363062).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Transform.scale(
          scale: isSelected ? 1.1 : 1.0,
          child: Image.asset(
            iconPath,
            color: isSelected
                ? const Color(0xFF363062)
                : Colors.grey.shade400,
            width: 24,
            height: 24,
          ),
        ),
      ),
      label: label,
    );
  }
}

// Extension cho performance tốt hơn trong các Page
extension PageOptimization on StatefulWidget {
  Widget buildWithKeepAlive(Widget child) {
    return KeepAliveWrapper(child: child);
  }
}

class KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const KeepAliveWrapper({
    super.key,
    required this.child,
  });

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // quan trọng để giữ state
    return widget.child;
  }
}