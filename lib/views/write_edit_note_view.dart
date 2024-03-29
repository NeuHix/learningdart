import 'package:flutter/material.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:learningdart/services/auth/auth_service.dart';
import 'package:learningdart/services/crud/notes_service.dart';
import 'package:learningdart/utilities/get_arguments.dart';

class WriteEditNoteView extends StatefulWidget {
  const WriteEditNoteView({Key? key}) : super(key: key);

  @override
  State<WriteEditNoteView> createState() => _WriteEditNoteViewState();
}

class _WriteEditNoteViewState extends State<WriteEditNoteView> {
  DatabaseNote? _note;

  late final NotesService _notesService;
  late final TextEditingController _textController;

  Future<DatabaseNote> createOrGetExistingNote(BuildContext) async {

    final widgetNote = context.getArgument<DatabaseNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final email = AuthService.firebase().currentUser!.email!;
    final owner = await _notesService.getUser(email: email);
    // _notesService.createNote(owner: owner);
    final newNote = await _notesService.createNote(owner: owner);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (text.isNotEmpty && note != null) {
      await _notesService.updateNote(
        note: note,
        text: text,
      );
    }
  }

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
    _textController = TextEditingController();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(
      note: note,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(() {
      _textControllerListener();
    });
    _textController.addListener(() {
      _textControllerListener();
    });
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _saveNoteIfNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Write Here"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(BuildContext),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                style: const TextStyle(fontSize: 20),
                autofocus: true,
                maxLines: null,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.all(20)),
              );
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(notesPage, (route) => false);
        },
        label: const Text(
          "back",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 18,
          ),
        ),
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Colors.black54,
        ),
      ),
    );
  }
}
