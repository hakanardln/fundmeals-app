import 'dart:ui';
import 'dart:async'; // Tambahkan untuk Timer
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'home_screen.dart';
import 'menu_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MenuScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Memungkinkan konten scroll di bawah navbar
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 24.0),
        child: LiquidGlassNavBar(
          selectedIndex: _selectedIndex,
          onItemSelected: _onItemTapped,
        ),
      ),
    );
  }
}

class LiquidGlassNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const LiquidGlassNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  State<LiquidGlassNavBar> createState() => _LiquidGlassNavBarState();
}

class _LiquidGlassNavBarState extends State<LiquidGlassNavBar> {
  double? _dragX;
  bool _showBubble = false;
  Timer? _hideTimer;

  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.restaurant_menu_rounded,
    Icons.receipt_long_rounded,
    Icons.person_rounded,
  ];

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _showBubbleTemporarily() {
    setState(() { _showBubble = true; });
    _hideTimer?.cancel();
    // Beri waktu animasi geser selesai (300ms) + sedikit delay sebelum menghilang
    _hideTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted && _dragX == null) {
        setState(() { _showBubble = false; });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double navBarWidth = constraints.maxWidth;
        final double tabWidth = navBarWidth / _icons.length;
        
        // Posisi target X saat ini (entah dari jari atau dari index terpilih)
        final double targetX = _dragX ?? (widget.selectedIndex * tabWidth + (tabWidth / 2));
        
        // Apakah sedang digeser?
        final bool isDragging = _dragX != null;

        return GestureDetector(
          onPanDown: (_) {
            _hideTimer?.cancel();
            setState(() { _showBubble = true; });
          },
          onPanUpdate: (details) {
            setState(() {
              _dragX = details.localPosition.dx.clamp(0.0, navBarWidth);
              _showBubble = true;
            });
          },
          onPanEnd: (details) {
            if (_dragX != null) {
              int nearestIndex = (_dragX! / tabWidth).floor();
              if (nearestIndex < 0) nearestIndex = 0;
              if (nearestIndex >= _icons.length) nearestIndex = _icons.length - 1;
              
              widget.onItemSelected(nearestIndex);
              setState(() {
                _dragX = null;
              });
            }
            _showBubbleTemporarily();
          },
          onPanCancel: () {
            setState(() {
              _dragX = null;
            });
            _showBubbleTemporarily();
          },
          child: SizedBox(
            height: 70,
            child: Stack(
              clipBehavior: Clip.none, // Allow bubble to overflow top/bottom
              children: [
                // 1. Navbar Glass Background (Pill Shape)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(35),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.7),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                  // 2. Tetesan Air / Liquid Drop yang bergerak (Iridescent Bubble)
                AnimatedPositioned(
                  duration: isDragging ? const Duration(milliseconds: 100) : const Duration(milliseconds: 700),
                  curve: isDragging ? Curves.easeOut : Curves.elasticOut, // Efek 'jelly' (kenyal) saat dilepas
                  left: targetX - 35, // Lebar bubble 70
                  top: -5, // Tinggi 80, Navbar 70. Overflow atas bawah 5.
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: _showBubble ? 1.0 : 0.0,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 600),
                      scale: _showBubble ? 1.0 : 0.8,
                      curve: Curves.elasticOut, // Mengembang secara kenyal seperti gelembung air
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                          child: Container(
                            width: 70,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              // Gradien ini menyatu dengan kaca, tengahnya bening, ujungnya chromatic tipis
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0x5500FFFF), // Cyan tipis (opacity 33%)
                                  Color(0x33FF00FF), // Magenta sangat tipis
                                  Color(0x33FFFFFF), // Kaca putih bening (tengah)
                                  Color(0x33FFFFFF), // Kaca putih bening (tengah)
                                  Color(0x33FFFF00), // Kuning sangat tipis
                                  Color(0x5500FFFF), // Cyan tipis (opacity 33%)
                                ],
                                // Stops diketatkan agar warna-warninya HANYA ada di ujung 5%
                                stops: [0.0, 0.05, 0.15, 0.85, 0.95, 1.0],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.6), // Garis luar kaca
                                width: 0.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.15),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // 3. Ikon Navigasi
                Positioned.fill(
                  child: Row(
                      children: List.generate(_icons.length, (index) {
                        final bool isSelected = widget.selectedIndex == index;
                        // Jarak antara ikon dengan target posisi air
                        // Digunakan untuk membuat efek ikon 'menyala/membesar' ketika air mendekat
                        final double distance = (targetX - (index * tabWidth + (tabWidth / 2))).abs();
                        final double proximity = (1 - (distance / tabWidth)).clamp(0.0, 1.0);
                        
                        // Menentukan warna dan ukuran ikon (berubah jadi hijau gelap saat 'terendam' air bening)
                        final Color iconColor = Color.lerp(
                          AppColors.gray500,
                          AppColors.primary,
                          proximity,
                        )!;
                        
                        return Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                widget.onItemSelected(index);
                                _showBubbleTemporarily();
                              },
                              child: SizedBox(
                              height: 70,
                              child: Icon(
                                _icons[index],
                                color: iconColor,
                                size: 24 + (4 * proximity), // Ikon membesar saat didekati air
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
