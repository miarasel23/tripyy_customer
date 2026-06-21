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
  final Function(SearchLocationData)? onDestinationSelected;
  final Function(bool isDropFocused)? onFocusChanged;

  const SearchAndSavedCardWidget({
    super.key,
    required this.loc,
    this.onPickupSelected,
    this.onDestinationSelected,
    this.onFocusChanged,
  });

  @override
  SearchAndSavedCardWidgetState createState() => SearchAndSavedCardWidgetState();
}

class SearchAndSavedCardWidgetState extends State<SearchAndSavedCardWidget> {
  final List<TextEditingController> _pickupControllers = [TextEditingController()];
  final List<FocusNode> _pickupFocusNodes = [FocusNode()];
  final TextEditingController _destController = TextEditingController();
  final FocusNode _destFocusNode = FocusNode();
  late SearchLocationBloc _bloc;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isDropActive = false;

  void _setupFocusListener(FocusNode node) {
    node.addListener(() {
      if (_destFocusNode.hasFocus) {
        _isDropActive = true;
      } else if (_pickupFocusNodes.any((n) => n.hasFocus)) {
        _isDropActive = false;
      }

      bool anyFocused = _pickupFocusNodes.any((n) => n.hasFocus) || _destFocusNode.hasFocus;
      if (anyFocused) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
      widget.onFocusChanged?.call(_isDropActive);
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _bloc = SearchLocationBloc(SearchLocationRepository());
    _setupFocusListener(_pickupFocusNodes[0]);
    _setupFocusListener(_destFocusNode);

    _bloc.stream.listen((state) {
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
                      constraints: const BoxConstraints(maxHeight: 240),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                for (var n in _pickupFocusNodes) n.unfocus();
                                _destFocusNode.unfocus();
                              },
                            ),
                          ),
                          Flexible(
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
                              int pickupIndex = _pickupFocusNodes.indexWhere((n) => n.hasFocus);
                              if (pickupIndex != -1) {
                                _pickupControllers[pickupIndex].text = loc.address ?? "";
                                _pickupFocusNodes[pickupIndex].unfocus();
                                if (widget.onPickupSelected != null && pickupIndex == 0) {
                                  widget.onPickupSelected!(loc);
                                }
                              } else if (_destFocusNode.hasFocus) {
                                _destController.text = loc.address ?? "";
                                _destFocusNode.unfocus();
                                if (widget.onDestinationSelected != null) {
                                  widget.onDestinationSelected!(loc);
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
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
    for (var c in _pickupControllers) { c.dispose(); }
    for (var n in _pickupFocusNodes) { n.dispose(); }
    _destController.dispose();
    _destFocusNode.dispose();
    _bloc.close();
    super.dispose();
  }

  bool get isDropFocused => _isDropActive;

  /// Called externally (e.g., from map drag) to update the active field
  void updateActiveFieldText(String address) {
    setState(() {
      if (_isDropActive) {
        _destController.text = address;
      } else {
        // Find exactly which pickup field has focus, or use the first one
        bool found = false;
        for (int i = 0; i < _pickupFocusNodes.length; i++) {
          if (_pickupFocusNodes[i].hasFocus) {
            _pickupControllers[i].text = address;
            found = true;
            break;
          }
        }
        if (!found && _pickupControllers.isNotEmpty) {
          _pickupControllers[0].text = address;
        }
      }
    });
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
              IntrinsicHeight(
                child: Row(
                  children: [
                    // timeline dots
                    Column(
                      children: [
                        const SizedBox(height: 24), // Approx center of first field
                        for (int i = 0; i < _pickupControllers.length; i++) ...[
                          if (i > 0) Expanded(child: Container(width: 2, color: Colors.grey.withOpacity(0.3))),
                          const Icon(Icons.circle, size: 8, color: Colors.grey),
                        ],
                        Expanded(child: Container(width: 2, color: Colors.grey.withOpacity(0.3))),
                        Icon(Icons.square, size: 8, color: Colors.blue[200]),
                        const SizedBox(height: 24), // Approx center of last field
                      ],
                    ),
                    const SizedBox(width: 8),
                    // text fields
                    Expanded(
                      child: Column(
                        children: [
                          for (int i = 0; i < _pickupControllers.length; i++) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _pickupControllers[i],
                                            focusNode: _pickupFocusNodes[i],
                                            onChanged: (val) {
                                              _bloc.add(SearchQueryChanged(val, widget.loc.locale.languageCode));
                                            },
                                            decoration: InputDecoration(
                                              hintText: i == 0 ? (widget.loc.translate("pick_up_location") ?? "Pick up location") : "Add stop",
                                              border: InputBorder.none,
                                              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                            ),
                                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                          ),
                                        ),
                                        if (i > 0)
                                          IconButton(
                                            icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                                            onPressed: () {
                                              setState(() {
                                                _pickupControllers[i].dispose();
                                                _pickupFocusNodes[i].dispose();
                                                _pickupControllers.removeAt(i);
                                                _pickupFocusNodes.removeAt(i);
                                              });
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (i == 0) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        final newController = TextEditingController();
                                        final newNode = FocusNode();
                                        _setupFocusListener(newNode);
                                        _pickupControllers.add(newController);
                                        _pickupFocusNodes.add(newNode);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.add, color: Theme.of(context).colorScheme.surface, size: 18),
                                    ),
                                  ),
                                ] else ...[
                                  const SizedBox(width: 8),
                                  const SizedBox(width: 30), // Placeholder to keep field widths consistent
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextField(
                                    controller: _destController,
                                    focusNode: _destFocusNode,
                                    onChanged: (val) {
                                      _bloc.add(SearchQueryChanged(val, widget.loc.locale.languageCode));
                                    },
                                    decoration: InputDecoration(
                                      hintText: widget.loc.translate("where_are_you_going") ?? "Where to?",
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                    ),
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.my_location, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Divider(color: Theme.of(context).colorScheme.outlineVariant, height: 4, thickness: 1),
              const SizedBox(height: 8),
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
