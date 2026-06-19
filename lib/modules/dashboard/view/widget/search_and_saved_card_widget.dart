import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/localization/app_localization.dart';
import '../../../../routes/app_routes.dart';
import '../../../searchLocation/models/search_location_model.dart';
import '../../../searchLocation/controller/search_location_bloc.dart';
import '../../../searchLocation/repository/search_location_repository.dart';

class SearchAndSavedCardWidget extends StatefulWidget {
  final AppLocalizations loc;
  final Function(SearchLocationData)? onPickupSelected;

  const SearchAndSavedCardWidget({Key? key, required this.loc, this.onPickupSelected}) : super(key: key);

  @override
  State<SearchAndSavedCardWidget> createState() => _SearchAndSavedCardWidgetState();
}

class _SearchAndSavedCardWidgetState extends State<SearchAndSavedCardWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late SearchLocationBloc _bloc;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _bloc = SearchLocationBloc(SearchLocationRepository());
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
      setState(() {});
    });

    _bloc.stream.listen((state) {
      // Rebuild the overlay when the bloc state changes
      _overlayEntry?.markNeedsBuild();
    });
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 40, // Full width of the card
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.topLeft,
          followerAnchor: Alignment.bottomLeft,
          offset: const Offset(0, -4), // Floats just 4px above the top of the card
          child: BlocProvider.value(
            value: _bloc,
            child: BlocBuilder<SearchLocationBloc, SearchLocationState>(
              builder: (context, state) {
                if (state is SearchLocationLoading) {
                  return Material(
                    elevation: 8.0,
                    borderRadius: BorderRadius.circular(16),
                    child: const SizedBox(
                      height: 50,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                } else if (state is SearchLocationSuccess && state.locations.isNotEmpty) {
                  return Material(
                    elevation: 8.0,
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: state.locations.length,
                        separatorBuilder: (_, __) => Divider(height: 1, thickness: 0.5, color: Colors.grey.withOpacity(0.3)),
                        itemBuilder: (context, index) {
                          final loc = state.locations[index];
                          final parts = (loc.address ?? "").split(',');
                          final title = parts.first;
                          final subtitle = parts.length > 1 ? parts.skip(1).join(',').trim() : "";

                          return ListTile(
                            leading: const Icon(Icons.location_on, color: Colors.blue),
                            title: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
                            subtitle: subtitle.isNotEmpty
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 2), // 2px line break height
                                      Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                                    ],
                                  )
                                : null,
                            onTap: () {
                              _searchController.text = loc.address ?? "";
                              _focusNode.unfocus();
                              if (widget.onPickupSelected != null) {
                                widget.onPickupSelected!(loc);
                              }
                            },
                          );
                        },
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink(); // Hide overlay if nothing is found or empty
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _searchController.dispose();
    _focusNode.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Container(
          padding: const EdgeInsets.all(20),
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
                      const Icon(Icons.circle, size: 8, color: Colors.grey),
                      Container(height: 30, width: 2, color: Colors.grey.withOpacity(0.3)),
                      Icon(Icons.square, size: 8, color: Colors.blue[200]),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // text fields
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            onChanged: (val) {
                              _bloc.add(SearchQueryChanged(val, widget.loc.locale.languageCode));
                            },
                            decoration: InputDecoration(
                              hintText: widget.loc.translate("pick_up_location") ?? "Pick up location",
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(widget.loc.translate("where_are_you_going") ?? "Where to?", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Action buttons
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add, color: Theme.of(context).colorScheme.surface),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
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
              const SizedBox(height: 20),
              Divider(color: Theme.of(context).colorScheme.outlineVariant),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSavedLocItem(context, Icons.home, widget.loc.translate("home") ?? "Home", "2.4 KM", () {
                    Navigator.pushNamed(context, AppRoutes.savedLoc);
                  }),
                  Container(width: 1, height: 30, color: Theme.of(context).colorScheme.outlineVariant),
                  _buildSavedLocItem(context, Icons.work, widget.loc.translate("work") ?? "Work", "8.1 KM", () {
                    Navigator.pushNamed(context, AppRoutes.savedLoc);
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedLocItem(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
          ),
          const SizedBox(width: 12),
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
