import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:testrunflutter/data/firebase/ChatRepository.dart';
import 'package:testrunflutter/data/models/Chat/ChatMessage.dart';
import 'package:testrunflutter/data/models/Chat/Conversation.dart';
import 'package:testrunflutter/data/models/UserModel.dart';
import 'package:testrunflutter/features/Pages/chat/Cubit/ChatList/ChatListCubit.dart';
import 'package:testrunflutter/features/Pages/chat/Cubit/ChatList/ChatListState.dart';
import 'package:testrunflutter/features/Pages/chat/screens/ChatPage.dart';
import 'package:provider/provider.dart';

class ChatListPage extends StatelessWidget {
  final String userId;
  const ChatListPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => ChatRepository(),
      child: BlocProvider(
        create: (context) => ChatListCubit(
          repository: context.read<ChatRepository>(),
          userId: userId,
        ),
        child: const ChatListView(),
      ),
    );
  }
}

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: BlocBuilder<ChatListCubit, ChatListState>(
        builder: (context, state) {
          if (state is ChatListLoading) {
            return _buildLoadingState();
          }

          if (state is ChatListError) {
            return _buildErrorState(context, state.message);
          }

          if (state is ChatListLoaded) {
            final conversations = state.conversations;

            if (conversations.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ChatListCubit>().loadConversations();
              },
              color: Colors.green[600],
              backgroundColor: Colors.white,
              strokeWidth: 3,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: conversations.length,
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(left: 80.w),
                  child: Divider(height: 1, color: Colors.grey[200]),
                ),
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  return ConversationTile(
                    conversation: conversation,
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => ChatPage(
                            conversationId: conversation.id,
                            currentUserId: conversation.userId,
                            currentUserType: "user",
                            shopName: conversation.shopName,
                            shopAvatar: conversation.shopAvatar,
                          ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOutCubic;
                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);
                            return SlideTransition(position: offsetAnimation, child: child);
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                    onDelete: () => _showDeleteDialog(context, conversation),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      title: _isSearching
          ? TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm cuộc trò chuyện...',
          border: InputBorder.none,
          hintStyle: TextStyle(fontSize: 16.sp, color: Colors.grey[400]),
        ),
        style: TextStyle(fontSize: 16.sp, color: Colors.black87),
        onChanged: (value) {
          if (value.isNotEmpty) {
            context.read<ChatListCubit>().searchConversations(value);
          } else {
            context.read<ChatListCubit>().loadConversations();
          }
        },
      )
          : Text(
        'Tin nhắn',
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: IconButton(
            key: ValueKey(_isSearching),
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: Colors.black87,
              size: 24.sp,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<ChatListCubit>().loadConversations();
                }
              });
            },
          ),
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
            strokeWidth: 3,
          ),
          SizedBox(height: 16.h),
          Text(
            'Đang tải danh sách...',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, size: 64.r, color: Colors.red[400]),
            ),
            SizedBox(height: 24.h),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600], height: 1.5),
            ),
            SizedBox(height: 32.h),
            FilledButton.icon(
              onPressed: () => context.read<ChatListCubit>().loadConversations(),
              icon: Icon(Icons.refresh_rounded, size: 20.sp),
              label: Text('Thử lại', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[50]!, Colors.green[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 80.r,
                color: Colors.green[400],
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              _isSearching ? 'Không tìm thấy kết quả' : 'Chưa có cuộc trò chuyện',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              _isSearching
                  ? 'Thử tìm kiếm với từ khóa khác'
                  : 'Bắt đầu trò chuyện với cửa hàng\nđể đặt câu hỏi hoặc hỗ trợ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Conversation conversation) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        contentPadding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
        title: Text(
          'Xóa cuộc trò chuyện',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn có chắc muốn xóa cuộc trò chuyện với ${conversation.shopName}? Hành động này không thể hoàn tác.',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[700], height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              context.read<ChatListCubit>().deleteConversation(conversation.id);
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.white, size: 20.sp),
                      SizedBox(width: 12.w),
                      const Text('Đã xóa cuộc trò chuyện'),
                    ],
                  ),
                  backgroundColor: Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  margin: EdgeInsets.all(16.r),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text('Xóa', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final unreadCount = conversation.userUnreadCount;
    final hasUnread = unreadCount > 0;

    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        onDelete();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red[400]!, Colors.red[600]!],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white, size: 28.sp),
            SizedBox(height: 4.h),
            Text(
              'Xóa',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        color: Colors.white,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Hero(
                        tag: 'shop_avatar_${conversation.id}',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: hasUnread
                                ? [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ]
                                : null,
                          ),
                          child: CircleAvatar(
                            radius: 28.r,
                            backgroundColor: Colors.green[50],
                            backgroundImage: conversation.shopAvatar != null
                                ? NetworkImage(conversation.shopAvatar!)
                                : null,
                            child: conversation.shopAvatar == null
                                ? Icon(
                              Icons.store_rounded,
                              color: Colors.green[600],
                              size: 28.sp,
                            )
                                : null,
                          ),
                        ),
                      ),
                      if (hasUnread)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 14.r,
                            height: 14.r,
                            decoration: BoxDecoration(
                              color: Colors.green[600],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                conversation.shopName,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                                  color: Colors.black87,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              _formatTime(conversation.updatedAt),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: hasUnread ? Colors.green[600] : Colors.grey[500],
                                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _getLastMessagePreview(conversation),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: hasUnread ? Colors.black87 : Colors.grey[600],
                                  fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasUnread) ...[
                              SizedBox(width: 10.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.green[500]!, Colors.green[600]!],
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                constraints: BoxConstraints(minWidth: 22.r, minHeight: 22.r),
                                child: Text(
                                  unreadCount > 99 ? '99+' : '$unreadCount',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getLastMessagePreview(Conversation conversation) {
    if (conversation.lastMessage == null) {
      return 'Chưa có tin nhắn';
    }

    final message = conversation.lastMessage!;

    if (message.type == MessageType.image) {
      return '📷 Hình ảnh';
    } else if (message.type == MessageType.file) {
      return '📎 Tệp đính kèm';
    } else if (message.type == MessageType.location) {
      return '📍 Vị trí';
    }

    return message.text.isNotEmpty ? message.text : 'Tin nhắn mới';
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      final weekdays = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
      return weekdays[dateTime.weekday - 1];
    } else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }
}