import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/app_layout.dart';

class EditDirectBookingPage extends StatelessWidget {
  const EditDirectBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLayout(
      currentPage: '/edit-direct-booking',
      title: 'Edit Direct Booking',
      child: Center(
        child: Text('Edit Direct Booking Page - Coming Soon'),
      ),
    );
  }
}
