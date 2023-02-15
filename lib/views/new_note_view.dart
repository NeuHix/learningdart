// import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/material.dart';
import 'package:learningdart/constants/routes.dart';
import 'package:learningdart/services/auth/auth_service.dart';
import 'package:learningdart/services/crud/notes_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({Key? key}) : super(key: key);

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNote? _note;
  final currentColor = const Color(0xffc2e7ff);
  // DatabaseNote? tempNote;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    // final tempExistingNote = tempNote;
    if (existingNote != null) {
      return existingNote;
    }
    // if (tempExistingNote != null) {
    //   return tempExistingNote;
    //
    // }
    final email = AuthService.firebase().currentUser!.email!;
    final owner = await _notesService.getUser(email: email);
    // _notesService.createNote(owner: owner);
    return _notesService.createNote(owner: owner);
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
    _textController = TextEditingController();
    super.initState();
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
        backgroundColor: currentColor,
      ),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNote;
              _setupTextControllerListener();

              return const Text("Cool!");
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
              .pushNamedAndRemoveUntil(NotesPage, (route) => false);
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
        backgroundColor: currentColor,
      ),
    );
  }
}