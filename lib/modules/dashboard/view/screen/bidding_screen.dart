import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/localization/app_localization.dart';
import '../../models/create_rental_trip_model.dart';
import '../../repository/create_trip_repository.dart';

class BiddingScreen extends StatefulWidget {
  final String customerUuid;

  const BiddingScreen({super.key, required this.customerUuid});

  @override
  State<BiddingScreen> createState() => _BiddingScreenState();
}

class _BiddingScreenState extends State<BiddingScreen> {
  late Timer _pollingTimer;
  final CreateTripRepository _repo = CreateTripRepository();
  bool _isLoading = true;
  List<RentalDriverBid> _bids = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _fetchBids(); // Initial fetch
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchBids();
    });
  }

  Future<void> _fetchBids() async {
    try {
      final loc = AppLocalizations.of(context);
      final response = await _repo.fetchBids(
        customerUuid: widget.customerUuid,
        langCode: loc.locale.languageCode,
      );

      if (mounted) {
        setState(() {
          _bids = response.drivers;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _pollingTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("bidding") ?? "Bidding"),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _bids.isEmpty) {
      return Center(
        child: Text("Error fetching bids: $_errorMessage"),
      );
    }

    if (_bids.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              "Waiting for bids from drivers...",
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _bids.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final bid = _bids[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              "Bid Amount: ${bid.bidAmount ?? 'N/A'}",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Driver: ${bid.name ?? 'Unknown'}"),
            trailing: ElevatedButton(
              onPressed: () {
                // Handle Accept Bid
              },
              child: const Text("Accept"),
            ),
          ),
        );
      },
    );
  }
}
