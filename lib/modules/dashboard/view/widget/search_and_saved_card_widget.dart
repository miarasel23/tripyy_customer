import 'package:flutter/material.dart';
import '../../../../core/utils/localization/app_localization.dart';
import '../../../../routes/app_routes.dart';

class SearchAndSavedCardWidget extends StatelessWidget {
  final AppLocalizations loc;

  const SearchAndSavedCardWidget({Key? key, required this.loc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // timeline dots
              Column(
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.grey),
                  Container(height: 30, width: 2, color: Colors.grey.withOpacity(0.3)),
                  Icon(Icons.square, size: 8, color: Colors.blue[200]),
                ],
              ),
              SizedBox(width: 16),
              // text fields
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(loc.translate("current_location") ?? "Current Location", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(loc.translate("where_are_you_going") ?? "Where to?", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              // Action buttons
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, color: Theme.of(context).colorScheme.surface),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.my_location, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSavedLocItem(context, Icons.home, loc.translate("home") ?? "Home", "2.4 KM", () {
                Navigator.pushNamed(context, AppRoutes.savedLoc);
              }),
              Container(width: 1, height: 30, color: Theme.of(context).colorScheme.outlineVariant),
              _buildSavedLocItem(context, Icons.work, loc.translate("work") ?? "Work", "8.1 KM", () {
                Navigator.pushNamed(context, AppRoutes.savedLoc);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavedLocItem(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
