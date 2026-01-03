import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/forum/forum_bloc.dart';
import '../../blocs/forum/forum_event.dart';
import '../../blocs/forum/forum_state.dart';
import '../../config/app_theme.dart';
import '../../models/forum_topic.dart';
import '../../widgets/custom_widgets.dart';

/// Screen Edit Post (UPDATE)
class ForumEditScreen extends StatefulWidget {
  final ForumTopic topic;

  const ForumEditScreen({super.key, required this.topic});

  @override
  State<ForumEditScreen> createState() => _ForumEditScreenState();
}

class _ForumEditScreenState extends State<ForumEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedCategory;
  late bool _isAnonymous;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.topic.title);
    _descriptionController = TextEditingController(
      text: widget.topic.description,
    );
    _selectedCategory = widget.topic.category;
    _isAnonymous = widget.topic.isAnonymous;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<ForumBloc>().add(
        ForumUpdateRequested(
          topicId: widget.topic.id,
          title: _titleController.text.trim(),
          category: _selectedCategory,
          description: _descriptionController.text.trim(),
          isAnonymous: _isAnonymous,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Post')),
      body: BlocListener<ForumBloc, ForumState>(
        listener: (context, state) {
          if (state is ForumOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successColor,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is ForumError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Anda sedang mengedit post yang sudah ada',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                CustomTextField(
                  controller: _titleController,
                  label: 'Judul Post',
                  hint: 'Tulis judul yang menarik',
                  prefixIcon: Icons.title,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    if (value.length < 5) {
                      return 'Judul minimal 5 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: ForumCategories.categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Description
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Isi Post',
                  hint: 'Ceritakan apa yang ingin Anda bagikan...',
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Isi post tidak boleh kosong';
                    }
                    if (value.length < 20) {
                      return 'Isi minimal 20 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Anonymous option
                Card(
                  child: CheckboxListTile(
                    value: _isAnonymous,
                    onChanged: (value) {
                      setState(() {
                        _isAnonymous = value ?? false;
                      });
                    },
                    title: const Text('Post sebagai Anonim'),
                    subtitle: const Text(
                      'Nama Anda tidak akan ditampilkan',
                      style: TextStyle(fontSize: 12),
                    ),
                    secondary: const Icon(Icons.visibility_off_outlined),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                const SizedBox(height: 24),
                // Submit Button
                BlocBuilder<ForumBloc, ForumState>(
                  builder: (context, state) {
                    return CustomButton(
                      text: 'Simpan Perubahan',
                      onPressed: _onSubmit,
                      isLoading: state is ForumLoading,
                      icon: Icons.save,
                      width: double.infinity,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
