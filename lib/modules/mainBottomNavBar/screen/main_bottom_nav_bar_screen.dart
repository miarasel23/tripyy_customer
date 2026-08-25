import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/localization/app_localization.dart';
import '../../dashboard/screen/dashboard_screen.dart';
import '../../myTrip/screen/myTrip_screen.dart';
import '../../profile/screen/profile_screen.dart';


import '../controller/main_bottom_nav_bar_bloc.dart';
import '../controller/main_bottom_nav_bar_event.dart';
import '../controller/main_bottom_nav_bar_state.dart';

class MainBottomNavBarScreen extends StatefulWidget {
  const MainBottomNavBarScreen({super.key});

  @override
  State<MainBottomNavBarScreen> createState() => _MainBottomNavBarScreenState();
}

class _MainBottomNavBarScreenState extends State<MainBottomNavBarScreen> {
  List<Widget> get _screens => const [
    ProfileScreen(),
    MytripScreen(),
    DashboardScreen(),
  ];

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1C1E26) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.translate("exit_app_title"),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  loc.translate("exit_app_message"),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: isDark ? Colors.white24 : Colors.grey.shade300,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          loc.translate("cancel"),
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          loc.translate("exit_app_confirm"),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final state = context.read<MainBottomNavBarBloc>().state;
        if (state.selectedIndex != 2) {
          context.read<MainBottomNavBarBloc>().add(ChangeTabEvent(2));
        } else {
          final shouldExit = await _showExitConfirmationDialog(context);
          if (shouldExit && context.mounted) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: BlocBuilder<MainBottomNavBarBloc, MainBottomNavBarState>(
          builder: (context, state) {
            return _screens[state.selectedIndex];
          },
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.grey,
          ),
          child: BlocBuilder<MainBottomNavBarBloc, MainBottomNavBarState>(
            builder: (context, state) {
              return BottomNavigationBar(
                selectedFontSize: 14,
                unselectedFontSize: 14,
                elevation: 0,
                currentIndex: state.selectedIndex,
                selectedItemColor: Theme.of(context).colorScheme.onSurface,
                unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Theme.of(context).colorScheme.surface,
                onTap: (index) {
                  context.read<MainBottomNavBarBloc>().add(ChangeTabEvent(index));
                },
                items: [
                  BottomNavigationBarItem(
                    icon: IconTheme(
                      data: IconThemeData(
                        color: state.selectedIndex == 0
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.grey,
                      ),
                      child: Icon(Icons.person),
                    ),
                    label: loc.translate("profile"),
                  ),
                  BottomNavigationBarItem(
                    icon: IconTheme(
                      data: IconThemeData(
                        color: state.selectedIndex == 1
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.grey,
                      ),
                      child: Icon(Icons.train_sharp),
                    ),
                    label: loc.translate("my_trip"),
                  ),
                  BottomNavigationBarItem(
                    icon: IconTheme(
                      data: IconThemeData(
                        color: state.selectedIndex == 2
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.grey,
                      ),
                      child: Icon(Icons.home_outlined),
                    ),
                    label: loc.translate("home"),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

