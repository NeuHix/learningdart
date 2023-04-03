import 'package:flutter/material.dart';
import '../services/crud/notes_service.dart';

class NotesListView extends StatelessWidget {

  final List<DatabaseNote> notes;

  const NotesListView({Key? key, required this.notes,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
