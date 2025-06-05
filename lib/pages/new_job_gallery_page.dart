import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/app_layout.dart';

class NewJobGalleryPage extends StatelessWidget {
  const NewJobGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLayout(
      currentPage: '/new-job-gallery',
      title: 'New Job Gallery',
      child: Center(child: Text('New Job Gallery Page - Coming Soon')),
    );
  }
}
