import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_router.dart';
import '../bloc/forum_bloc.dart';
import '../bloc/forum_event.dart';
import '../bloc/forum_state.dart';
import '../data/forum_model.dart';
import '../../_shared/widgets/custom_button.dart';

/// Halaman Form Forum (Create/Edit)
class ForumFormPage extends StatefulWidget {
  final bool isEdit;
  final ForumTopic? topic;

  const ForumFormPage({super.key, required this.isEdit, this.topic});

  @override
  State<ForumFormPage> createState() => _ForumFormPageState();
}

class _ForumFormPageState extends State<ForumFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = ForumCategory.categories.first;
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.topic != null) {
      _titleController.text = widget.topic!.title;
      _contentController.text = widget.topic!.content;
      _selectedCategory = widget.topic!.category;
      _isAnonymous = widget.topic!.isAnonymous;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      if (widget.isEdit && widget.topic != null) {
        context.read<ForumBloc>().add(
          ForumUpdateRequested(
            topicId: widget.topic!.id,
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            category: _selectedCategory,
          ),
        );
      } else {
        context.read<ForumBloc>().add(
          ForumCreateRequested(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            category: _selectedCategory,
            isAnonymous: _isAnonymous,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Topik' : 'Buat Topik Baru'),
      ),
      body: BlocListener<ForumBloc, ForumState>(
        listener: (context, state) {
          if (state is ForumOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successColor,
              ),
            );
            // Pop back to forum list and refresh
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kategori',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: ForumCategory.categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Judul',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan judul topik',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Isi',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText:
                        'Tuliskan isi diskusi Anda (minimal 20 karakter)...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Isi tidak boleh kosong';
                    }
                    if (value.length < 20) {
                      return 'Isi minimal 20 karakter';
                    }
                    return null;
                  },
                ),
                if (!widget.isEdit) ...[
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: _isAnonymous,
                    onChanged: (value) {
                      setState(() {
                        _isAnonymous = value ?? false;
                      });
                    },
                    title: const Text('Posting sebagai Anonim'),
                    subtitle: const Text('Nama Anda tidak akan ditampilkan'),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
                const SizedBox(height: 24),
                BlocBuilder<ForumBloc, ForumState>(
                  builder: (context, state) {
                    return CustomButton(
                      text: widget.isEdit ? 'Update' : 'Posting',
                      onPressed: _onSubmit,
                      isLoading: state is ForumLoading,
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
