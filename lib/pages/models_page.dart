import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/app_layout.dart';

class ModelsPage extends StatelessWidget {
  const ModelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/models',
      title: 'Models',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.pushNamed(context, '/new-model'),
        ),
      ],
      child: const Center(child: Text('Models Page - Coming Soon')),
    );
  }
}
