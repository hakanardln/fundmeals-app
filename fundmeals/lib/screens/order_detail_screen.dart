import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../providers/order_provider.dart';
import '../../providers/review_provider.dart';
import '../../widgets/common_widgets.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().getOrderDetail(widget.orderId);
    });
  }

  List<Map<String, String>> _getStatusSteps() {
    return [
      {'status': 'waiting_payment', 'label': 'Order Placed', 'desc': 'Pesanan Anda telah dibuat dan menunggu pembayaran.'},
      {'status': 'waiting_confirmation', 'label': 'Pending', 'desc': 'Menunggu konfirmasi dari pihak restoran.'},
      {'status': 'processing', 'label': 'Confirmed', 'desc': 'Pesanan Anda sedang diproses oleh restoran.'},
      {'status': 'ready', 'label': 'Processing', 'desc': 'Pesanan siap dan menunggu kurir/pengambilan.'},
      {'status': 'completed', 'label': 'Delivered', 'desc': 'Pesanan telah selesai! Selamat menikmati.'},
    ];
  }

  int _getStatusIndex(String status) {
    switch (status.toLowerCase()) {
      case 'waiting_payment':
      case 'pending':
        return 0;
      case 'waiting_confirmation':
        return 1;
      case 'processing':
      case 'preparing':
        return 2;
      case 'ready':
      case 'on_delivery':
        return 3;
      case 'completed':
      case 'delivered':
        return 4;
      default:
        return 0; // Default to first step if cancelled or unknown
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoading) {
            return const LoadingWidget(message: 'Loading order...');
          }

          if (orderProvider.error != null) {
            return ErrorStateWidget(
              message: orderProvider.error!,
              onRetry: () {
                orderProvider.getOrderDetail(widget.orderId);
              },
            );
          }

          final order = orderProvider.selectedOrder;
          if (order == null) {
            return EmptyStateWidget(
              message: 'Order not found',
              icon: Icons.error_outline,
            );
          }

          final steps = _getStatusSteps();
          final currentIndex = _getStatusIndex(order.status);
          final timeFormat = DateFormat('hh:mm a');

          return Column(
            children: [
              // 1. Green Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  bottom: 40,
                  left: 20,
                  right: 20,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Order details',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24), // Balance spacing for back button
                  ],
                ),
              ),

              // 2. Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: Column(
                    children: [
                      // Timeline Tracker
                      ...List.generate(steps.length, (index) {
                        final step = steps[index];
                        final isCompleted = index <= currentIndex;
                        final isLast = index == steps.length - 1;
                        
                        // We use the order's created time for the first step as a mock,
                        // ideally the API provides timestamps for each transition.
                        final stepTime = index == 0 
                            ? timeFormat.format(order.createdAt)
                            : (isCompleted ? timeFormat.format(order.updatedAt) : '--:--');

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Time
                              SizedBox(
                                width: 70,
                                child: Text(
                                  stepTime,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                                    color: isCompleted ? AppColors.textPrimary : AppColors.textTertiary,
                                  ),
                                ),
                              ),
                              
                              // Indicator & Line
                              Column(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCompleted ? AppColors.primary : const Color(0xFFE5E7EB),
                                    ),
                                    child: isCompleted
                                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                                        : null,
                                  ),
                                  if (!isLast)
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        color: isCompleted ? AppColors.primary : const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              
                              // Content
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 30.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        step['label']!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isCompleted ? AppColors.textPrimary : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        step['desc']!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isCompleted ? AppColors.textSecondary : AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      
                      const SizedBox(height: 20),

                      // Description / Items Card (Green)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                children: order.items.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF7ED), // Soft orange/peach like image
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(Icons.fastfood_rounded, color: Colors.orange, size: 30),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.productName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Rp ${NumberFormat('#,###', 'id_ID').format(item.subtotal)}',
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: AppColors.border),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Text(
                                                      'Qty: ${item.quantity}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors.textSecondary,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                          ],
                        ),
                      ),
                      
                      if (order.status == 'completed' || order.status == 'selesai') ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => _showReviewDialog(context, order.restaurantId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              'Beri Ulasan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showReviewDialog(BuildContext context, int storeId) {
    int rating = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Beri Ulasan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: Colors.orange,
                          size: 40,
                        ),
                        onPressed: () {
                          setStateModal(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Tulis ulasan Anda di sini...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Consumer<ReviewProvider>(
                    builder: (context, reviewProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: reviewProvider.isLoading
                              ? null
                              : () async {
                                  final success = await reviewProvider.addReview(
                                    storeId: storeId,
                                    rating: rating,
                                    comment: commentController.text,
                                  );
                                  if (context.mounted) {
                                    if (success) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Ulasan berhasil dikirim!'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(reviewProvider.error ?? 'Gagal mengirim ulasan'),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: reviewProvider.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Kirim Ulasan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
