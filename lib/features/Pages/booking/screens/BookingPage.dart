import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingWithShop.dart';
import 'package:testrunflutter/data/models/UserModel.dart';
import 'package:testrunflutter/data/repositories/prefs/UserPrefsService.dart';
import 'package:testrunflutter/features/Pages/booking/cubit/booking_cubit.dart';
import 'package:testrunflutter/features/Pages/booking/cubit/booking_state.dart';
import 'package:testrunflutter/features/Pages/booking/cubit/history/historyCubit.dart';
import 'package:testrunflutter/features/Pages/booking/cubit/history/historyState.dart';
import 'package:testrunflutter/features/Pages/booking/screens/Active/ActiveBooking.dart';
import 'package:testrunflutter/features/Pages/booking/screens/History/History.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  FireStoreDatabase dtb = FireStoreDatabase();
  UserModel? _userModel;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final userData = await UserPrefsService.getUser() ?? await dtb.getUserByEmail();
    if (userData != null) {
      setState(() {
        _userModel = userData;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_userModel == null) return Center(child: CircularProgressIndicator());

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => BookingCubit(idUser: _userModel!.id),
        ),
        BlocProvider(
          create: (_) => HistoryCubit(idUser: _userModel!.id),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xFF363062),
            body: SafeArea(
              child: Column(
                children: [
                  // Phần trên (hình ảnh và Row)
                  Expanded(
                    child: Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Image.asset(
                            'assets/icons/setIcon.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12.r),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              customText(
                                text: 'Lịch trình',
                                color: Colors.white,
                                fonSize: 16.sp,
                                fonWeight: FontWeight.bold,
                              ),
                              Image.asset('assets/logos/logov1.png'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Phần dưới (Container)
                  // Thanh chuyển tabs trong Container
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.83,
                    color: Colors.grey[50],
                    child: Column(
                      children: [
                        SizedBox(height: 20), // khoảng cách trên
                        Container(
                          width: 300,
                          height: 50,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color(0xFFF1F3FE),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Stack(
                            children: [
                              AnimatedAlign(
                                duration: Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                alignment: selectedIndex == 0
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: Container(
                                  width: 145,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  _buildTab("Lịch trình ", 0),
                                  _buildTab("Lịch sử", 1),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Phần nội dung dưới tùy theo tab
                        Expanded(
                          child: selectedIndex == 0
                              ? BlocBuilder<BookingCubit,BookingState>(builder: (context,state){
                                if(state is BookingLoading){
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }else if(state is BookingLoaded){
                                  List<BookingWithShop> list = state.list;
                                  return ActiveBooking(list);
                                }else if(state is BookingError){
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 60.sp,
                                          color: Colors.red[400],
                                        ),
                                        SizedBox(height: 16.h),
                                        Text(
                                          'Có lỗi xảy ra',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red[600],
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          state.message,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox();
                          })
                              : BlocBuilder<HistoryCubit,HistoryState>(builder: (context,state){
                                if(state is HistoryLoading){
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }else if(state is HistoryLoaded){
                                  List<BookingWithShop> list = state.list;
                                  return HistoryBooking(list);
                                }else if(state is HistoryError){
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 60.sp,
                                          color: Colors.red[400],
                                        ),
                                        SizedBox(height: 16.h),
                                        Text(
                                          'Có lỗi xảy ra',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red[600],
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          state.message,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return SizedBox();
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: Container(
          height: 42,
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
