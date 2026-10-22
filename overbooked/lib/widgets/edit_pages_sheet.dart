import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../providers/bookshelf_provider.dart';
import '../theme/app_theme.dart';

/// Bottom sheet for manually entering or correcting a book's page count.
class EditPagesSheet extends StatefulWidget {
  final Book book;
  final String userId;

  const EditPagesSheet({
    super.key,
    required this.book,
    required this.userId,
  });

  @override
  State<EditPagesSheet> createState() => _EditPagesSheetState();
}

class _EditPagesSheetState extends State<EditPagesSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.book.pageCount?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final pages = int.parse(_controller.text.trim());
    context.read<BookshelfProvider>().updatePageCount(
          widget.book.id,
          pages,
          widget.userId,
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Número de páginas atualizado!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Editar número de páginas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Livro: ${widget.book.title}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Atualmente: ${widget.book.pageCount?.toString() ?? 'Não informado'}',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
              decoration: const InputDecoration(
                labelText: 'Número de páginas',
                prefixIcon: Icon(
                  Icons.format_list_numbered,
                  color: AppTheme.secondaryText,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o número de páginas';
                }
                final n = int.tryParse(value.trim());
                if (n == null || n <= 0) {
                  return 'Informe um número válido maior que 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Salvar'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
