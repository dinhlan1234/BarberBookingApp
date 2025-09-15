import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/data/models/ServiceModel.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';
import 'package:testrunflutter/features/Pages/home/widgets/TabContent/AboutTab.dart';
import 'package:testrunflutter/features/Pages/home/widgets/TabContent/ReviewsTab.dart';
import 'package:testrunflutter/features/Pages/home/widgets/TabContent/ScheduleTab.dart';
import 'package:testrunflutter/features/Pages/home/widgets/TabContent/Services.dart';

Widget buildTabContent({required int index, required ShopModel shop, required List<ServiceModel> listServices}) {
  switch (index) {
    case 0:
      return buildAboutTab(shop,listServices);
    case 1:
      return buildServicesTab(shop,listServices);
    case 2:
      return TabSchedule();
    case 3:
      return Reviewstab();
    default:
      return SizedBox.shrink();
  }
}


