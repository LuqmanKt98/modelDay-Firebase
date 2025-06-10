import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/theme/app_theme.dart';
import 'package:new_flutter/widgets/ui/button.dart';
import 'package:new_flutter/widgets/ui/input.dart' as ui;
import 'package:new_flutter/models/community_post.dart';

class CommunityPostDetailPage extends StatefulWidget {
  final CommunityPost post;

  const CommunityPostDetailPage({
    super.key,
    required this.post,
  });

  @override
  State<CommunityPostDetailPage> createState() => _CommunityPostDetailPageState();
}

class _CommunityPostDetailPageState extends State<CommunityPostDetailPage> {
  final _commentController = TextEditingController();
  final List<Comment> _comments = [];
  bool _isLoading = false;
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    // Parse title and description from content
    final lines = widget.post.content.split('\n');
    final title = lines.isNotEmpty ? lines[0] : 'Untitled';
    final description = lines.length > 1 ? lines.skip(1).join('\n').trim() : '';

    _titleController = TextEditingController(text: title);
    _descriptionController = TextEditingController(text: description);
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading comments - replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Add some mock comments
    _comments.addAll([
      Comment(
        id: '1',
        author: 'John Doe',
        content: 'This sounds interesting! I might be able to help.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Comment(
        id: '2',
        author: 'Jane Smith',
        content: 'I have experience with similar projects. Feel free to reach out!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      author: 'Current User', // Replace with actual user name
      content: _commentController.text.trim(),
      timestamp: DateTime.now(),
    );

    setState(() {
      _comments.insert(0, newComment);
      _commentController.clear();
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _saveEdit() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call to update post
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isEditing = false;
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildPostContent() {
    if (_isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ui.Input(
            label: 'Title',
            controller: _titleController,
          ),
          const SizedBox(height: 16),
          ui.Input(
            label: 'Description',
            controller: _descriptionController,
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Button(
                  variant: ButtonVariant.outline,
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      // Reset to original content
                      final lines = widget.post.content.split('\n');
                      final title = lines.isNotEmpty ? lines[0] : 'Untitled';
                      final description = lines.length > 1 ? lines.skip(1).join('\n').trim() : '';
                      _titleController.text = title;
                      _descriptionController.text = description;
                    });
                  },
                  text: 'Cancel',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Button(
                  onPressed: _isLoading ? null : _saveEdit,
                  text: _isLoading ? 'Saving...' : 'Save',
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.post.content.split('\n').isNotEmpty
                    ? widget.post.content.split('\n')[0]
                    : 'Untitled',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: AppTheme.goldColor),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              tooltip: 'Edit Post',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.goldColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            widget.post.category ?? 'General',
            style: const TextStyle(
              color: AppTheme.goldColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.post.content.split('\n').length > 1
              ? widget.post.content.split('\n').skip(1).join('\n').trim()
              : widget.post.content,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.person, size: 16, color: Colors.grey[400]),
            const SizedBox(width: 8),
            Text(
              widget.post.authorName,
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(width: 16),
            Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
            const SizedBox(width: 8),
            Text(
              _formatTimestamp(widget.post.timestamp),
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
        if (widget.post.location != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Text(
                widget.post.location!,
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ],
        if (widget.post.date != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Text(
                widget.post.date!,
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comments',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        
        // Add comment form
        Row(
          children: [
            Expanded(
              child: ui.Input(
                controller: _commentController,
                placeholder: 'Write a comment...',
                maxLines: 3,
              ),
            ),
            const SizedBox(width: 16),
            Button(
              onPressed: _isLoading ? null : _addComment,
              text: 'Post Comment',
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Comments list
        if (_isLoading && _comments.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (_comments.isEmpty)
          const Center(
            child: Text(
              'No comments yet. Be the first to comment!',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final comment = _comments[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900]!.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.author,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatTimestamp(comment.timestamp),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      comment.content,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/community-board',
      title: 'Post Details',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostContent(),
            const SizedBox(height: 32),
            const Divider(color: Colors.grey),
            const SizedBox(height: 32),
            _buildCommentSection(),
          ],
        ),
      ),
    );
  }
}

class Comment {
  final String id;
  final String author;
  final String content;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.author,
    required this.content,
    required this.timestamp,
  });
}
