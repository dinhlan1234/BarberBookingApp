import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:testrunflutter/core/notification/Notification.dart';
import 'package:testrunflutter/data/models/BankInfoModel.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingDateModel.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingSchedules.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingWithShop.dart';
import 'package:testrunflutter/data/models/BookingModel/ReviewModel.dart';
import 'package:testrunflutter/data/models/BookingModel/ServicesSelected.dart';
import 'package:testrunflutter/data/models/BookingWithUser.dart';
import 'package:testrunflutter/data/models/Chat/ChatMessage.dart';
import 'package:testrunflutter/data/models/Chat/Conversation.dart';
import 'package:testrunflutter/data/models/LikeModel.dart';
import 'package:testrunflutter/data/models/LocationModel.dart';
import 'package:testrunflutter/data/models/RatingModel.dart';
import 'package:testrunflutter/data/models/ServiceModel.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';
import 'package:testrunflutter/data/models/ShopWithDistance.dart';
import 'package:testrunflutter/data/models/TransactionHistory/TransactionHistory.dart';
import 'package:testrunflutter/data/models/UserModel.dart';
import 'package:testrunflutter/data/models/cccdModel.dart';
import 'package:testrunflutter/data/repositories/prefs/UserPrefsService.dart';
import 'package:testrunflutter/data/repositories/services/FCMService.dart';

class FireStoreDatabase {
  // dang xuat
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // lấy thông tin user
  Future<UserModel?> getUserByEmail() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final email = currentUser?.email;
    if (email == null) return null;

    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return UserModel.fromFireStore(doc.data(), doc.id);
    } else {
      return null;
    }
  }

  // Nap tien -> user
  Future<double> rechargeUser(String amount, String id) async {
    final docRef = FirebaseFirestore.instance.collection('Users').doc(id);
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      final moneyOld = data?['money'] ?? '0';
      final currentMoney = double.tryParse(moneyOld) ?? 0.0;
      final amountToAdd = double.tryParse(amount) ?? 0.0;
      final newMoney = currentMoney + amountToAdd;
      await docRef.update({'money': newMoney.toString()});

      List<String> parts = amount.split('.');
      final int money = int.tryParse(parts[0]) ?? 0;

      final formatted = NumberFormat.decimalPattern('vi').format(money);

      showNotification(
        'Nạp tiền thành công!',
        'Bạn đã nạp thành công số tiền $formatted',
      );
      return newMoney;
    } else {
      print('Không tìm thấy người dùng.');
      return 0;
    }
  }

  // lấy số tiền
  Future<String?> getMoney(String id) async {
    final docs = await FirebaseFirestore.instance
        .collection('Users')
        .doc(id)
        .get();
    if (docs.exists) {
      final data = docs.data();
      final money = data?['money'];
      return money;
    }
    return null;
  }

  // cập nhật thông tin user
  Future<void> saveUser(UserModel user) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.id)
          .update(user.toJson());
      await UserPrefsService.saveUser(user);
    } catch (e) {
      print(e);
    }
  }

  // thay đổi mật khẩu
  Future<String?> changePassword(String oldPassword, String newPassword) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      if (user == null || user.email == null) {
        return "Không có người dùng đăng nhập";
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return "Mật khẩu cũ không đúng";
      } else if (e.code == 'weak-password') {
        return "Mật khẩu mới quá yếu";
      } else {
        return "Lỗi: ${e.message}";
      }
    } catch (e) {
      return "Lỗi không xác định: $e";
    }
  }


  // Đăng ký doanh nghiệp
  Future<void> registerShop(String shopName,
      String ownerName,
      String email,
      String phone,
      String shopAvatarImageUrl,
      String backgroundImageUrl,
      LocationModel location,
      String openHour,
      String closeHour,
      List<String> openDays,
      CccdModel cccd,
      String licenseImage,
      BankInfoModel bankInfo,) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('BusinessRegistration')
          .doc();
      String randomId = docRef.id;
      String today = getCurrentDate();
      final shop = ShopModel(
          randomId,
          shopName,
          ownerName,
          cccd,
          email,
          phone,
          shopAvatarImageUrl,
          backgroundImageUrl,
          location,
          openHour,
          closeHour,
          openDays,
          '0',
          today,
          'Chưa xử lý',
          '0.0',
          licenseImage,
          bankInfo,
          '0');
      await docRef.set(shop.toJson());
    } catch (e) {
      print(e);
    }
  }

  // lấy shop gần nhất
  Future<List<ShopWithDistance>> nearestShops(double lat, double lon) async {
    List<ShopWithDistance> listShop = [];
    final snapshot = await FirebaseFirestore.instance.collection('Shops').get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final shop = ShopModel.fromJson({
        'id': doc.id,
        ...data
      });
      final locationModel = shop.location;
      final double latShop = locationModel.latitude;
      final double lonShop = locationModel.longitude;

      double distanceInMeters = Geolocator.distanceBetween(
          lat, lon, latShop, lonShop);
      double distanceKm = distanceInMeters / 1000;
      if (distanceKm < 10) {
        double roundedDistance = double.parse(distanceKm.toStringAsFixed(1));
        final docSnapshot = await FirebaseFirestore.instance.collection(
            'RatingShops').doc(shop.id).get();
        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          final shopWithDistance = ShopWithDistance(shop: shop,
              ratingModel: RatingModel.fromJson(data!),
              distanceKm: roundedDistance);
          listShop.add(shopWithDistance);
        } else {
          print('khong tim thay du lieu rating');
        }
      }
    }
    return listShop;
  }


  // lấy danh sách dịch vụ của shop
  Future<List<ServiceModel>> getService(String id) async {
    List<ServiceModel> listServices = [];
    try {
      final query = await FirebaseFirestore.instance.collection('Services')
          .where('shopID', isEqualTo: id)
          .get();
      listServices = query.docs.map((doc) {
        final data = doc.data();
        return ServiceModel.fromJson({
          'serviceId': doc.id,
          ...data
        });
      }).toList();
    } catch (e) {
      print(e);
    }
    return listServices;
  }


  // dat lich
  Future<bool> booking(String idUser, String idShop,
      ServicesSelected servicesSelected, BookingDateModel bookingDateModel,
      String status) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('BookingSchedules')
          .doc();
      final randomID = docRef.id;
      final bookingSchedules = BookingSchedules(idSchedules: randomID,
          idUser: idUser,
          idShop: idShop,
          servicesSelected: servicesSelected,
          time: Timestamp.now(),
          bookingDateModel: bookingDateModel,
          status: status,
          reviewModel: null);
      await docRef.set(bookingSchedules.toJson());
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // kiem tra so tien
  Future<bool> checkAmount(String idUser, double total) async {
    final docs = await FirebaseFirestore.instance.collection('Users').doc(
        idUser).get();
    if (docs.exists) {
      final data = docs.data();
      final money = data?['money'];
      final subtraction = double.parse(money) - total;
      if (subtraction < 0) {
        return false;
      } else {
        await FirebaseFirestore.instance.collection('Users').doc(idUser).update(
            {
              'money': subtraction.toString()
            });
        return true;
      }
    } else {
      print('khong tim thay user');
      return false;
    }
  }


  // Cập nhật FCMToken
  Future<void> updateFcmToken(String id) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('Users').doc(id).update({
          'fcmToken': token
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // gui thong bao
  Future<bool> sendNotification(
      {required String object, required String id, required String title, required String body}) async {
    try {
      final docs = await FirebaseFirestore.instance.collection(object)
          .doc(id)
          .get();
      if (docs.exists) {
        final data = docs.data();
        final fcmToken = data?['fcmToken'];
        if (fcmToken != null) {
          bool success = await FCMService.sendFCMNotification(
            title: title,
            body: body,
            fcmToken: fcmToken,
          );
          if (success) {
            print('Gửi thành công');
            return true;
          } else {
            return false;
          }
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }


  // lấy danh sách thời gian đã đặt
  Future<List<String>> getBookedTimes(String shopId, String date) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("BookingSchedules")
          .where("idShop", isEqualTo: shopId)
          .where("bookingDateModel.date", isEqualTo: date)
          .get();

      return snapshot.docs
          .map((doc) => (doc.data()["bookingDateModel"]["time"] as String))
          .toList();
    } catch (e) {
      print("Lỗi khi lấy booked times: $e");
      return [];
    }
  }

  // lay lich su lich hen
  Future<List<BookingWithShop>> getHistoryForUser(String idUser) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('BookingSchedules')
          .where('idUser', isEqualTo: idUser)
          .where('status', whereIn: ['Hoàn thành1', 'Hoàn thành2'])
          .get();
      final bookings = docSnapshot.docs.map((doc) =>
          BookingSchedules.fromJson(doc.data())).toList();
      final bookingWithShops = await Future.wait(bookings.map((b) async {
        final shopDoc = await FirebaseFirestore.instance
            .collection('Shops')
            .doc(b.idShop)
            .get();

        final shop = ShopModel.fromJson({
          'id': shopDoc.id,
          ...shopDoc.data()!,
        });
        return BookingWithShop(booking: b, shop: shop);
      }));
      return bookingWithShops;
    } catch (e) {
      print(e);
      return [];
    }
  }


  // Cập nhật trạng thái đơn
  Future<bool> updateStatus(BookingSchedules bookingSchedules) async {
    try {
      await FirebaseFirestore.instance.collection('BookingSchedules').doc(
          bookingSchedules.idSchedules).update({
        'status': 'Đã đến'
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // review
  Future<bool> review(BookingSchedules bookingSchedules,
      ReviewModel review) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('BookingSchedules')
          .doc(bookingSchedules.idSchedules);
      await docRef.update({
        'reviewModel': review.toJson()
      });
      final docRating = FirebaseFirestore.instance.collection('RatingShops')
          .doc(bookingSchedules.idShop);
      final docRatingSnapshot = await docRating.get();
      if (docRatingSnapshot.exists) {
        final data = docRatingSnapshot.data();
        final int oldQuantity = (data?['quantity'] as num).toInt();
        final double oldRating = (data?['rating'] as num).toDouble();


        int newQuantity = oldQuantity + 1;
        double newRating = ((oldRating * oldQuantity) + review.rating) /
            newQuantity;
        await docRating.update({
          'quantity': newQuantity,
          'rating': newRating
        });
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // lay khoang cách
  Future<double> getDistance(double lat, double lon, ShopModel shop) async {
    try {
      final double latShop = shop.location.latitude;
      final double lonShop = shop.location.longitude;
      double distanceInMeters = Geolocator.distanceBetween(
          lat, lon, latShop, lonShop);
      double distanceKm = distanceInMeters / 1000;
      double roundedDistance = double.parse(distanceKm.toStringAsFixed(1));
      return roundedDistance;
    } catch (e) {
      print(e);
      return 0.0;
    }
  }

  // lay nhung quan duoc danh gia nhieu nhat
  Future<List<ShopWithDistance>> getMostRated(double lat, double lon) async {
    List<ShopWithDistance> list = [];
    try {
      final ratingSnapshot = await FirebaseFirestore.instance.collection(
          'RatingShops').orderBy('rating', descending: true).limit(10).get();
      for (var doc in ratingSnapshot.docs) {
        final ratingData = doc.data();
        final ratingModel = RatingModel.fromJson(ratingData);
        final shopSnapshot = await FirebaseFirestore.instance
            .collection('Shops')
            .doc(ratingModel.idShop)
            .get();
        if (shopSnapshot.exists) {
          final shop = ShopModel.fromJson(shopSnapshot.data()!);
          final locationModel = shop.location;
          final double latShop = locationModel.latitude;
          final double lonShop = locationModel.longitude;
          double distanceInMeters = Geolocator.distanceBetween(
              lat, lon, latShop, lonShop);
          double distanceKm = distanceInMeters / 1000;
          list.add(ShopWithDistance(
              shop: shop, ratingModel: ratingModel, distanceKm: distanceKm));
        }
      }
    } catch (e) {
      print(e);
    }
    return list;
  }

  // lay danh sach danh gia cua shop
  Future<List<BookingWithUser>> getListBookingRate(String idShop) async {
    List<BookingWithUser> list = [];
    // Lấy danh sách booking theo idShop
    final bookingSnapshot = await FirebaseFirestore.instance
        .collection('BookingSchedules')
        .where('idShop', isEqualTo: idShop)
        .get();

    for (var doc in bookingSnapshot.docs) {
      final data = doc.data();
      final review = data['reviewModel'];
      if (review != null) {
        final booking = BookingSchedules.fromJson(data);

        // Lấy idUser từ data booking
        final idUser = data['idUser'];
        if (idUser == null) continue;

        // Lấy thông tin user từ Users collection
        final userSnapshot = await FirebaseFirestore.instance.collection(
            'Users').doc(idUser).get();

        if (!userSnapshot.exists) continue;

        final userData = userSnapshot.data();
        if (userData == null) continue;

        final userModel = UserModel.fromFireStore(userData, idUser);

        // Gộp lại thành BookingWithUser
        final bookingWithUser =
        BookingWithUser(booking: booking, userModel: userModel);

        list.add(bookingWithUser);
      }
    }

    return list;
  }

  //kiem tra da like hay chua
  Future<bool> checkLike(String idShop, String idUser) async {
    final likeRef = FirebaseFirestore.instance
        .collection('Likes')
        .doc(idShop)
        .collection('Users')
        .doc(idUser);
    final likeSnapshot = await likeRef.get();
    if (likeSnapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  //Them hoac huy like
  Future<void> likeOrDislike(String idShop, String idUser,
      LikeModel likeModel) async {
    final docRef = FirebaseFirestore.instance
        .collection('Likes')
        .doc(idShop)
        .collection('Users')
        .doc(idUser);
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      await docRef.delete();
    } else {
      await docRef.set(likeModel.toJson());
    }
  }

  // lay danh sach nguoi da like
  Future<List<UserModel>> getUserLiked(String idShop) async {
    final docSnapshot = await FirebaseFirestore.instance.collection('Likes')
        .doc(idShop).collection('Users')
        .get();
    final listLike = docSnapshot.docs.map((doc) {
      final data = doc.data();
      return LikeModel.fromJson(data);
    }).toList();

    final listUser = await Future.wait(listLike.map((b) async {
      final userSnapshot = await FirebaseFirestore.instance.collection('Users')
          .doc(b.idUser)
          .get();
      final data = userSnapshot.data();
      return UserModel.fromFireStore(data!, b.idUser);
    }));
    return listUser;
  }

  // luu lich su giao dich
  Future<void> saveTransactionHistory(String userId,
      BookingWithShop? bookingWithShop, double totalAmount, double balance,
      String status) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('TransactionHistory')
          .doc();
      String id = docRef.id;
      if (bookingWithShop == null) {
        final transactionHistory = TransactionHistory(transactionCode: id,
            userId: userId,
            timestamp: Timestamp.now(),
            totalAmount: totalAmount,
            balance: balance,
            status: status);
        await docRef.set(transactionHistory.toJson());
      } else {
        final transactionHistory = TransactionHistory(transactionCode: id,
            userId: userId,
            bookingWithShop: bookingWithShop,
            timestamp: Timestamp.now(),
            totalAmount: totalAmount,
            balance: balance,
            status: status);
        await docRef.set(transactionHistory.toJson());
      }
    } catch (e) {
      print(e);
    }
  }


  // lấy ngày tháng năm hiện tại
  String getCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(now);
  }
}
