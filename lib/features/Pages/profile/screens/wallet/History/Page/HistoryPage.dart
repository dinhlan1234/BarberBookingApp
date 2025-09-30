import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/data/models/TransactionHistory/TransactionHistory.dart';
import 'package:testrunflutter/features/Pages/profile/screens/wallet/History/Cubit/DepositHistoryCubit.dart';
import 'package:testrunflutter/features/Pages/profile/screens/wallet/History/Cubit/DepositHistoryState.dart';

class HistoryPage extends StatelessWidget {
  final String id;

  const HistoryPage({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Lịch sử nạp/rút tiền',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white, size: 20.sp),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => DepositHistoryCubit(id: id),
        child: const DepositHistoryView(),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Bộ lọc',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.add_circle, color: Colors.green[600], size: 20.sp),
                title: Text('Chỉ nạp tiền', style: TextStyle(fontSize: 16.sp)),
                onTap: () {
                  Navigator.pop(context);
                  // Implement filter logic
                },
              ),
              ListTile(
                leading: Icon(Icons.remove_circle, color: Colors.red[600], size: 20.sp),
                title: Text('Chỉ rút tiền', style: TextStyle(fontSize: 16.sp)),
                onTap: () {
                  Navigator.pop(context);
                  // Implement filter logic
                },
              ),
              ListTile(
                leading: Icon(Icons.all_inclusive, color: Colors.blue[600], size: 20.sp),
                title: Text('Tất cả', style: TextStyle(fontSize: 16.sp)),
                onTap: () {
                  Navigator.pop(context);
                  // Implement filter logic
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class DepositHistoryView extends StatelessWidget {
  const DepositHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DepositHistoryCubit, DepositHistoryState>(
      builder: (context, state) {
        if (state is DepositHistoryLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Đang tải lịch sử giao dịch...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is DepositHistoryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.r,
                  color: Colors.red[300],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Có lỗi xảy ra',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
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
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<DepositHistoryCubit>().loadHistory();
                  },
                  icon: Icon(Icons.refresh, size: 20.sp),
                  label: Text('Thử lại', style: TextStyle(fontSize: 16.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is DepositHistoryLoaded) {
          final transactions = state.transactionHistory;

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 80.r,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Chưa có lịch sử giao dịch',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Các giao dịch nạp/rút tiền sẽ hiển thị tại đây',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          // Sắp xếp theo thời gian mới nhất
          transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          // Tách giao dịch theo loại
          final depositTransactions = transactions
              .where((t) => t.status == 'Nạp tiền')
              .toList();
          final withdrawTransactions = transactions
              .where((t) => t.status == 'Rút tiền')
              .toList();

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DepositHistoryCubit>().loadHistory();
            },
            color: Colors.blue[600],
            child: Column(
              children: [
                // Header thống kê
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(16.w),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[600]!, Colors.blue[700]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Tổng nạp',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  '${depositTransactions.length}',
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  _formatCurrency(_getTotalAmount(depositTransactions)),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1.w,
                            height: 60.h,
                            color: Colors.white30,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Tổng rút',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  '${withdrawTransactions.length}',
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  _formatCurrency(_getTotalAmount(withdrawTransactions)),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Tổng cộng: ${transactions.length} giao dịch',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Danh sách giao dịch
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return TransactionHistoryCard(transaction: transaction);
                    },
                  ),
                ),
              ],
            ),
          );
        }

        return SizedBox.shrink();
      },
    );
  }

  double _getTotalAmount(List<TransactionHistory> transactions) {
    return transactions.fold<double>(0, (sum, item) => sum + item.totalAmount);
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} VNĐ';
  }
}

class TransactionHistoryCard extends StatelessWidget {
  final TransactionHistory transaction;

  const TransactionHistoryCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isDeposit = transaction.status == 'Nạp tiền';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDeposit ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            _showTransactionDetails(context, transaction);
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    color: isDeposit ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Icon(
                    isDeposit ? Icons.add_circle : Icons.remove_circle,
                    color: isDeposit ? Colors.green[600] : Colors.red[600],
                    size: 24.sp,
                  ),
                ),

                SizedBox(width: 16.w),

                // Thông tin giao dịch
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            transaction.status,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            '${isDeposit ? '+' : '-'}${_formatCurrency(transaction.totalAmount)}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: isDeposit ? Colors.green[600] : Colors.red[600],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      Text(
                        'Mã GD: ${transaction.transactionCode}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Text(
                        _formatDate(transaction.timestamp),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                      SizedBox(height: 4.h),

                      Text(
                        'Số dư: ${_formatCurrency(transaction.balance)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue[600],
                        ),
                      ),

                      if (transaction.bookingWithShop != null) ...[
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'Liên quan đến booking',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} VNĐ';
  }

  String _formatDate(dynamic timestamp) {
    final date = timestamp.toDate();
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(date);
  }

  void _showTransactionDetails(BuildContext context, TransactionHistory transaction) {
    final isDeposit = transaction.status == 'Nạp tiền';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            Row(
              children: [
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    color: isDeposit ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Icon(
                    isDeposit ? Icons.add_circle : Icons.remove_circle,
                    color: isDeposit ? Colors.green[600] : Colors.red[600],
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chi tiết ${transaction.status.toLowerCase()}',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '${isDeposit ? '+' : '-'}${_formatCurrency(transaction.totalAmount)}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDeposit ? Colors.green[600] : Colors.red[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 32.h),

            _buildDetailRow('Mã giao dịch', transaction.transactionCode),
            _buildDetailRow('Loại giao dịch', transaction.status),
            _buildDetailRow('Số tiền', '${isDeposit ? '+' : '-'}${_formatCurrency(transaction.totalAmount)}'),
            _buildDetailRow('Số dư trước', _formatCurrency(transaction.balance - transaction.totalAmount)),
            _buildDetailRow('Số dư sau', _formatCurrency(transaction.balance)),
            _buildDetailRow('Thời gian', _formatDate(transaction.timestamp)),

            if (transaction.bookingWithShop != null)
              _buildDetailRow('Ghi chú', 'Giao dịch liên quan đến booking'),

            SizedBox(height: 32.h),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Implement share or export functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Chức năng chia sẻ đang được phát triển',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.share, size: 20.sp),
                    label: Text('Chia sẻ', style: TextStyle(fontSize: 16.sp)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue[600],
                      side: BorderSide(color: Colors.blue[600]!, width: 1.w),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Đóng',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}