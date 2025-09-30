import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testrunflutter/data/models/UserModel.dart';
import 'package:testrunflutter/data/repositories/prefs/UserPrefsService.dart';
import 'package:testrunflutter/features/Pages/booking/screens/BookingPage.dart';
import 'package:testrunflutter/features/Pages/chat/screens/ChatListPage.dart';
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
  UserModel? _currentUser;  // 👈 biến để lưu user

  List<Widget> _pages = []; // 👈 không để const vì cần truyền user

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadUser(); // 👈 gọi hàm async
  }

  Future<void> _loadUser() async {
    final user = await UserPrefsService.getUser(); // lấy user từ local
    setState(() {
      _currentUser = user;

      _pages = [
        const HomePage(),
        const BookingPage(),
        ChatListPage(userId: _currentUser!.id),
        const ProfilePage(),
      ];
    });
  }

  void _onTab(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nếu chưa có user thì show loading
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: CupertinoTabBar(
        activeColor: const Color(0xFF363062),
        inactiveColor: Colors.grey.shade400,
        currentIndex: _selectedIndex,
        onTap: _onTab,
        backgroundColor: Colors.transparent,
        items: [
          _buildOptimizedTab(
            iconPath: 'assets/icons/homeBottom.png',
            label: "Trang chủ",
            index: 0,
          ),
          _buildOptimizedTab(
            iconPath: 'assets/icons/calendarBottom2.png',
            label: "Lịch trình",
            index: 1,
          ),
          _buildOptimizedTab(
            iconPath: 'assets/icons/cahtBottom2.png',
            label: "Chat",
            index: 2,
          ),
          _buildOptimizedTab(
            iconPath: 'assets/icons/profileBottom.png',
            label: "Bạn",
            index: 3,
          ),
        ],
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
