import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/forum/forum_bloc.dart';
import '../../blocs/forum/forum_event.dart';
import '../../blocs/forum/forum_state.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../models/forum_topic.dart';
import '../../widgets/custom_widgets.dart';

/// Screen Buat Post Baru (CREATE)
class ForumCreateScreen extends StatefulWidget {
  const ForumCreateScreen({super.key});

  @override
  State<ForumCreateScreen> createState() => _ForumCreateScreenState();
}

class _ForumCreateScreenState extends State<ForumCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = ForumCategories.categories.first;
  bool _isAnonymous = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<ForumBloc>().add(
        ForumCreateRequested(
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
      appBar: AppBar(title: const Text('Buat Post Baru')),
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
                      text: 'Posting',
                      onPressed: _onSubmit,
                      isLoading: state is ForumLoading,
                      icon: Icons.send,
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
