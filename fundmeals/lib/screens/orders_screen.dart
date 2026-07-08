import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common_widgets.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Diproses', 'Selesai', 'Dibatalkan'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().getOrders(refresh: true);
    });
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'waiting_payment':
      case 'pending':
        return 'Menunggu';
      case 'waiting_confirmation':
      case 'processing':
      case 'preparing':
        return 'Diproses';
      case 'ready':
      case 'on_delivery':
        return 'Diantar';
      case 'completed':
      case 'delivered':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Diproses';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'waiting_payment':
      case 'pending':
      case 'waiting_confirmation':
        return const Color(0xFFF59E0B);
      case 'processing':
      case 'preparing':
        return const Color(0xFF3B82F6);
      case 'ready':
      case 'on_delivery':
        return const Color(0xFF8B5CF6);
      case 'completed':
      case 'delivered':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'waiting_payment':
      case 'pending':
        return Icons.payment_rounded;
      case 'waiting_confirmation':
      case 'processing':
      case 'preparing':
        return Icons.soup_kitchen_rounded;
      case 'ready':
      case 'on_delivery':
        return Icons.delivery_dining_rounded;
      case 'completed':
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA), // Light soft background
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          // Filter orders
          final allOrders = orderProvider.orders;
          final filteredOrders = allOrders.where((order) {
            if (_selectedFilter == 'All') return true;
            final label = _getStatusLabel(order.status);
            return label == _selectedFilter;
          }).toList();

          return Stack(
            children: [
              // 1. Top Header Background (Curved Gradient)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 280,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        Color(0xFF2A8B55), // Lighter green
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),
              ),

              // 2. Main Content Scroll
              SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Texts
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Riwayat Pesanan 🍽️',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Pantau terus status makananmu.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.history_rounded,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),

                    // 3. Floating Filter Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Pesanan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _filters.map((filter) {
                                final isSelected = _selectedFilter == filter;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedFilter = filter;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primary : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primary.withOpacity(0.3),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              )
                                            ]
                                          : [],
                                    ),
                                    child: Text(
                                      filter,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : AppColors.textSecondary,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 4. List of Orders
                    Expanded(
                      child: orderProvider.isLoading && allOrders.isEmpty
                          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                          : orderProvider.error != null && allOrders.isEmpty
                              ? ErrorStateWidget(
                                  message: orderProvider.error!,
                                  onRetry: () => orderProvider.getOrders(refresh: true),
                                )
                              : filteredOrders.isEmpty
                                  ? EmptyStateWidget(
                                      message: 'Belum ada pesanan di kategori ini.',
                                      icon: Icons.receipt_long_rounded,
                                      onRetry: () => orderProvider.getOrders(refresh: true),
                                    )
                                  : RefreshIndicator(
                                      onRefresh: () => orderProvider.getOrders(refresh: true),
                                      color: AppColors.primary,
                                      child: ListView.builder(
                                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                                        itemCount: filteredOrders.length,
                                        itemBuilder: (context, index) {
                                          final order = filteredOrders[index];
                                          final statusLabel = _getStatusLabel(order.status);
                                          final statusColor = _getStatusColor(order.status);
                                          final statusIcon = _getStatusIcon(order.status);
                                          
                                          // Get first item name or fallback
                                          final itemName = order.items.isNotEmpty 
                                              ? order.items.first.productName 
                                              : 'Order #${order.id}';
                                          
                                          // Formatted time
                                          final formattedTime = DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt);

                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(24),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.03),
                                                  blurRadius: 15,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              borderRadius: BorderRadius.circular(24),
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(24),
                                                onTap: () {
                                                  Navigator.of(context).pushNamed(
                                                    '/order-detail',
                                                    arguments: order.id,
                                                  );
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(20.0),
                                                  child: Row(
                                                    children: [
                                                      // Left Icon Area
                                                      Container(
                                                        padding: const EdgeInsets.all(16),
                                                        decoration: BoxDecoration(
                                                          color: statusColor.withOpacity(0.1),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                          statusIcon,
                                                          color: statusColor,
                                                          size: 28,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      
                                                      // Middle Text Area
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              itemName,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w700,
                                                                color: AppColors.textPrimary,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 6),
                                                            Row(
                                                              children: [
                                                                const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textTertiary),
                                                                const SizedBox(width: 4),
                                                                Text(
                                                                  formattedTime,
                                                                  style: const TextStyle(
                                                                    fontSize: 13,
                                                                    color: AppColors.textTertiary,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(height: 6),
                                                            Text(
                                                              'Rp ${NumberFormat('#,###', 'id_ID').format(order.totalPrice)} • ${order.items.length} item',
                                                              style: const TextStyle(
                                                                fontSize: 13,
                                                                fontWeight: FontWeight.w600,
                                                                color: AppColors.primary,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      
                                                      // Right Action Button
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                        decoration: BoxDecoration(
                                                          color: statusColor,
                                                          borderRadius: BorderRadius.circular(20),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: statusColor.withOpacity(0.3),
                                                              blurRadius: 8,
                                                              offset: const Offset(0, 3),
                                                            )
                                                          ]
                                                        ),
                                                        child: Row(
                                                          children: const [
                                                            Text(
                                                              'Detail',
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
