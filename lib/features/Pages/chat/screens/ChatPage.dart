import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:testrunflutter/data/firebase/ChatRepository.dart';
import 'package:testrunflutter/data/models/Chat/ChatMessage.dart';
import 'package:testrunflutter/features/Pages/chat/Cubit/Chat/ChatCubit.dart';
import 'package:testrunflutter/features/Pages/chat/Cubit/Chat/ChatState.dart';

class ChatPage extends StatelessWidget {
  final String conversationId;
  final String currentUserId;
  final String currentUserType;
  final String shopName;
  final String? shopAvatar;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.currentUserId,
    required this.currentUserType,
    required this.shopName,
    this.shopAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => ChatRepository(),
      child: BlocProvider(
        create: (context) => ChatCubit(
          repository: context.read<ChatRepository>(),
          conversationId: conversationId,
          currentUserId: currentUserId,
          currentUserType: currentUserType,
        ),
        child: ChatView(shopName: shopName, shopAvatar: shopAvatar),
      ),
    );
  }
}

class ChatView extends StatefulWidget {
  final String shopName;
  final String? shopAvatar;

  const ChatView({super.key, required this.shopName, this.shopAvatar});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _isComposing = _messageController.text.trim().isNotEmpty;
      });
    });

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(context),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          // Chỉ xử lý error
          if (state is ChatError) {
            _showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is ChatLoading) {
            return _buildLoadingState();
          }

          if (state is ChatLoaded) {
            final messages = state.messages;

            // Auto scroll khi có message mới
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients && messages.isNotEmpty) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                );
              }
            });

            return Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? _buildEmptyState()
                      : _buildMessagesList(context, messages),
                ),
                _buildInputArea(context),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: InkWell(
        onTap: () {
          // Navigate to shop info
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: [
              Hero(
                tag: 'shop_avatar_',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 20.r,
                    backgroundColor: Colors.green[50],
                    backgroundImage: widget.shopAvatar != null
                        ? NetworkImage(widget.shopAvatar!)
                        : null,
                    child: widget.shopAvatar == null
                        ? Icon(Icons.store_rounded, color: Colors.green[700], size: 22.sp)
                        : null,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.shopName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Container(
                          width: 8.r,
                          height: 8.r,
                          decoration: BoxDecoration(
                            color: Colors.green[500],
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Đang hoạt động',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.call_outlined, color: Colors.black87, size: 22.sp),
          onPressed: () {
            _showFeatureSnackBar(context, 'Tính năng gọi điện đang phát triển');
          },
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: Colors.black87, size: 22.sp),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          offset: Offset(0, 50.h),
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            _buildPopupMenuItem(Icons.info_outline, 'Thông tin cửa hàng', 'info'),
            _buildPopupMenuItem(Icons.search, 'Tìm kiếm tin nhắn', 'search'),
            _buildPopupMenuItem(Icons.notifications_off_outlined, 'Tắt thông báo', 'mute'),
            const PopupMenuDivider(),
            _buildPopupMenuItem(Icons.delete_outline, 'Xóa cuộc trò chuyện', 'delete', isDestructive: true),
          ],
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(IconData icon, String text, String value, {bool isDestructive = false}) {
    return PopupMenuItem<String>(
      value: value,
      height: 48.h,
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: isDestructive ? Colors.red[600] : Colors.grey[700]),
          SizedBox(width: 12.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDestructive ? Colors.red[600] : Colors.black87,
            ),
          ),
        ],
      ),
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
            'Đang tải tin nhắn...',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64.r,
              color: Colors.green[300],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Chưa có tin nhắn',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Bắt đầu cuộc trò chuyện ngay!',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context, List<ChatMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      physics: const BouncingScrollPhysics(),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final showDate = index == 0 ||
            !_isSameDay(messages[index - 1].timestamp, message.timestamp);

        return Column(
          children: [
            if (showDate) _buildDateDivider(message.timestamp),
            MessageBubble(
              message: message,
              isMe: message.senderId == context.read<ChatCubit>().currentUserId,
              shopAvatar: widget.shopAvatar,
              showAvatar: index == messages.length - 1 ||
                  messages[index + 1].senderId != message.senderId,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateDivider(DateTime date) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300], height: 1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                _formatDate(date),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300], height: 1)),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showAttachmentOptions(context),
                  borderRadius: BorderRadius.circular(24.r),
                  child: Container(
                    width: 42.r,
                    height: 42.r,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add_rounded, color: Colors.grey[700], size: 24.sp),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Container(
                  constraints: BoxConstraints(maxHeight: 120.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: 'Nhập tin nhắn...',
                            hintStyle: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.grey[500],
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 18.w,
                              vertical: 12.h,
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                          style: TextStyle(fontSize: 15.sp),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.emoji_emotions_outlined,
                          color: Colors.grey[600],
                          size: 24.sp,
                        ),
                        onPressed: () {
                          // TODO: Show emoji picker
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              AnimatedScale(
                scale: _isComposing ? 1.0 : 0.8,
                duration: const Duration(milliseconds: 200),
                child: Material(
                  color: _isComposing ? Colors.green[600] : Colors.grey[300],
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _isComposing ? () => _sendMessage(context) : null,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 42.r,
                      height: 42.r,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20.sp,
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
  }

  void _sendMessage(BuildContext context) {
    if (_messageController.text.trim().isEmpty) return;

    context.read<ChatCubit>().sendMessage(
      text: _messageController.text.trim(),
      senderType: 'user',
    );

    _messageController.clear();
    _focusNode.requestFocus();
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.only(top: 12.h, bottom: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                mainAxisSpacing: 16.h,
                crossAxisSpacing: 16.w,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildAttachmentGridOption(
                    icon: Icons.image_rounded,
                    label: 'Hình ảnh',
                    color: const Color(0xFF9C27B0),
                    onTap: () async {
                      Navigator.pop(context);
                      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        _showFeatureSnackBar(context, 'Tính năng đang phát triển');
                      }
                    },
                  ),
                  _buildAttachmentGridOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    color: const Color(0xFF2196F3),
                    onTap: () async {
                      Navigator.pop(context);
                      final image = await _imagePicker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        _showFeatureSnackBar(context, 'Tính năng đang phát triển');
                      }
                    },
                  ),
                  _buildAttachmentGridOption(
                    icon: Icons.attach_file_rounded,
                    label: 'Tệp',
                    color: const Color(0xFFFF9800),
                    onTap: () {
                      Navigator.pop(context);
                      _showFeatureSnackBar(context, 'Tính năng đang phát triển');
                    },
                  ),
                  _buildAttachmentGridOption(
                    icon: Icons.location_on_rounded,
                    label: 'Vị trí',
                    color: const Color(0xFFF44336),
                    onTap: () {
                      Navigator.pop(context);
                      _showFeatureSnackBar(context, 'Tính năng đang phát triển');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentGridOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icon, color: color, size: 28.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'info':
        _showFeatureSnackBar(context, 'Tính năng thông tin cửa hàng đang phát triển');
        break;
      case 'search':
        _showFeatureSnackBar(context, 'Tính năng tìm kiếm đang phát triển');
        break;
      case 'mute':
        _showFeatureSnackBar(context, 'Tính năng tắt thông báo đang phát triển');
        break;
      case 'delete':
        _showDeleteConfirmDialog(context);
        break;
    }
  }

  void _showDeleteConfirmDialog(BuildContext context) {
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
          'Bạn có chắc muốn xóa cuộc trò chuyện này? Hành động này không thể hoàn tác.',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Hủy',
              style: TextStyle(color: Colors.grey[700], fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
              _showSuccessSnackBar(context, 'Đã xóa cuộc trò chuyện');
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

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.all(16.r),
      ),
    );
  }

  void _showFeatureSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.all(16.r),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.all(16.r),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Hôm nay';
    } else if (messageDate == yesterday) {
      return 'Hôm qua';
    } else if (now.difference(date).inDays < 7) {
      final weekdays = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
      return weekdays[date.weekday - 1];
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final String? shopAvatar;
  final bool showAvatar;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.shopAvatar,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            showAvatar
                ? CircleAvatar(
              radius: 16.r,
              backgroundColor: Colors.green[100],
              backgroundImage: shopAvatar != null ? NetworkImage(shopAvatar!) : null,
              child: shopAvatar == null
                  ? Icon(Icons.store_rounded, color: Colors.green[600], size: 16.sp)
                  : null,
            )
                : SizedBox(width: 32.r),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageOptions(context),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      gradient: isMe
                          ? LinearGradient(
                        colors: [Colors.green[600]!, Colors.green[700]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : null,
                      color: isMe ? null : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        topRight: Radius.circular(20.r),
                        bottomLeft: isMe ? Radius.circular(20.r) : Radius.circular(4.r),
                        bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(20.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isMe
                              ? Colors.green.withOpacity(0.15)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.type == MessageType.image && message.imageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.network(
                              message.imageUrl!,
                              width: 220.w,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 220.w,
                                  height: 150.h,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.broken_image_rounded, size: 48.sp),
                                );
                              },
                            ),
                          ),
                        if (message.text.isNotEmpty)
                          Text(
                            message.text,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: isMe ? Colors.white : Colors.black87,
                              height: 1.4,
                              letterSpacing: 0.2,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isMe) ...[
                        SizedBox(width: 4.w),
                        Icon(
                          message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                          size: 16.sp,
                          color: message.isRead ? Colors.blue[400] : Colors.grey[400],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 8.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.copy_rounded, color: Colors.grey[700], size: 20.sp),
                ),
                title: Text('Sao chép', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.white, size: 20.sp),
                          SizedBox(width: 12.w),
                          const Text('Đã sao chép tin nhắn'),
                        ],
                      ),
                      backgroundColor: Colors.green[600],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      margin: EdgeInsets.all(16.r),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              if (isMe)
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.delete_outline_rounded, color: Colors.red[600], size: 20.sp),
                  ),
                  title: Text(
                    'Thu hồi tin nhắn',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.red[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Delete message
                  },
                ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
}