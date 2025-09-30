import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testrunflutter/data/models/Chat/ChatMessage.dart';
import 'package:testrunflutter/data/models/Chat/Conversation.dart';

class ChatRepository{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Lấy hoặc tạo conversation giữa user và shop
  Future<Conversation> getOrCreateConversation({
    required String userId,
    required String userName,
    String? userAvatar,
    required String shopId,
    required String shopName,
    String? shopAvatar,
    String? shopAddress,
  }) async {
    try {
      // Tìm conversation đã tồn tại
      final querySnapshot = await _firestore
          .collection('conversations')
          .where('participants', arrayContains: userId)
          .get();

      // Kiểm tra xem có conversation nào với shop này không
      for (var doc in querySnapshot.docs) {
        final conversation = Conversation.fromJson(doc.data());
        if (conversation.shopId == shopId) {
          return conversation;
        }
      }

      // Nếu chưa có, tạo mới
      final conversationRef = _firestore.collection('conversations').doc();
      final now = DateTime.now();

      final newConversation = Conversation(
        id: conversationRef.id,
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        shopId: shopId,
        shopName: shopName,
        shopAvatar: shopAvatar,
        shopAddress: shopAddress,
        participants: [userId, shopId],
        createdAt: now,
        updatedAt: now,
      );

      await conversationRef.set(newConversation.toJson());
      return newConversation;
    } catch (e) {
      throw Exception('Không thể tạo cuộc trò chuyện: $e');
    }
  }

  // 2. Lấy danh sách conversations của user
  Stream<List<Conversation>> getUserConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Conversation.fromJson(doc.data()))
          .toList();
    });
  }

  // 3. Lấy danh sách conversations của shop
  Stream<List<Conversation>> getShopConversations(String shopId) {
    return _firestore
        .collection('conversations')
        .where('shopId', isEqualTo: shopId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Conversation.fromJson(doc.data()))
          .toList();
    });
  }

  // 4. Gửi tin nhắn
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderType, // "user" hoặc "shop"
    required String text,
    String? imageUrl,
    String? fileUrl,
    String? fileName,
    MessageType type = MessageType.text,
  }) async {
    try {
      final messageRef = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc();

      final now = DateTime.now();

      final message = ChatMessage(
        id: messageRef.id,
        conversationId: conversationId,
        senderId: senderId,
        senderType: senderType,
        text: text,
        imageUrl: imageUrl,
        fileUrl: fileUrl,
        fileName: fileName,
        type: type,
        timestamp: now,
        isRead: false,
      );

      // Lưu message
      await messageRef.set(message.toJson());

      // Xác định field unreadCount cần tăng
      String unreadField =
      senderType == 'user' ? 'shopUnreadCount' : 'userUnreadCount';

      // Cập nhật conversation
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': message.toJson(),
        'updatedAt': Timestamp.fromDate(now),
        unreadField: FieldValue.increment(1),
      });

      return message;
    } catch (e) {
      throw Exception('Không thể gửi tin nhắn: $e');
    }
  }


  // 5. Lấy danh sách messages của conversation
  Stream<List<ChatMessage>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromJson(doc.data()))
          .toList();
    });
  }

  // 6. Đánh dấu tin nhắn đã đọc
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String currentUserId,
    required String currentUserType, // "user" hoặc "shop"
  }) async {
    try {
      // reset unreadCount cho chính mình
      await _firestore.collection('conversations').doc(conversationId).update({
        currentUserType == "user" ? 'userUnreadCount' : 'shopUnreadCount': 0,
      });

      // đồng thời update isRead cho các message chưa đọc
      final messagesSnapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: currentUserId)
          .get();

      final batch = _firestore.batch();
      for (var doc in messagesSnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Không thể đánh dấu đã đọc: $e');
    }
  }


  // 7. Xóa conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Xóa tất cả messages
      final messagesSnapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();

      for (var doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // Xóa conversation
      await _firestore.collection('conversations').doc(conversationId).delete();
    } catch (e) {
      throw Exception('Không thể xóa cuộc trò chuyện: $e');
    }
  }

  // 8. Tìm kiếm conversations
  Future<List<Conversation>> searchConversations({
    required String userId,
    required String keyword,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .where('userId', isEqualTo: userId)
          .get();

      final conversations = snapshot.docs
          .map((doc) => Conversation.fromJson(doc.data()))
          .where((conv) =>
      conv.shopName.toLowerCase().contains(keyword.toLowerCase()) ||
          (conv.lastMessage?.text ?? '')
              .toLowerCase()
              .contains(keyword.toLowerCase()))
          .toList();

      return conversations;
    } catch (e) {
      throw Exception('Không thể tìm kiếm: $e');
    }
  }

  // 9. Lấy một conversation cụ thể
  Future<Conversation?> getConversationById(String conversationId) async {
    try {
      final doc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (doc.exists) {
        return Conversation.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Không thể lấy thông tin conversation: $e');
    }
  }

  // 10. Cập nhật trạng thái online
  Future<void> updateOnlineStatus({
    required String userId,
    required bool isOnline,
  }) async {
    try {
      await _firestore.collection('userChatStatus').doc(userId).set({
        'id': userId,
        'isOnline': isOnline,
        'lastSeen': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Không thể cập nhật trạng thái: $e');
    }
  }

  // 11. Lắng nghe trạng thái online
  Stream<bool> listenOnlineStatus(String userId) {
    return _firestore
        .collection('userChatStatus')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data()?['isOnline'] ?? false;
      }
      return false;
    });
  }
}