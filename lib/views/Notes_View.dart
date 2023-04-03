import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev show log;
import 'package:learningdart/constants/routes.dart';
import 'package:learningdart/enums/menu_actions.dart';
import 'package:learningdart/services/auth/auth_service.dart';
import 'package:learningdart/services/crud/notes_service.dart';
import '../utilities/child_dialogs.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);
  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  String get userEmail {
    return AuthService.firebase().currentUser!.email!;
  }

  final _notesService = NotesService();

  // final currentColor = const Color(0xffc2e7ff);
  // final selectedColor = const Color(0xff9db1c7);
  int _selectedIndex = 0;

  
  String getUserName() {
    var userName = FirebaseAuth.instance.currentUser?.displayName;
    
    if (userName != null) {
      return userName;
    } else {
      userName = "your Notes!";
      return userName;
    }
  }
  
  final cool = FirebaseAuth.instance.currentUser?.reload();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    final notesServices = NotesService();
    AuthService.firebase().initialize();
    notesServices.dbExecuteNote();
    notesServices.ensureDBisOpen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getUserName()),
        actions: [
          /// "Plus" Icon to create a new note
          /// Moves to [NewNoteView] using Navigator.push and that
          /// adds a shortcut to return to [NotesView].
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, WriteEditNotePage);
            },
            icon: const Icon(Icons.add),
          ),

          /// This is just an option in the three-dot menu , which can be
          /// used to provide with actions to the user, As many as you like.
          /// Here it is: Log Out
          PopupMenuButton(
            onSelected: (value) async {
              switch (value) {
                case MenuActions.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    // Fluttertoast.showToast(msg: "Cool! Now Login Again.");
                    if (!mounted) {}
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginPage,
                      (route) => false,
                    );
                  } else {
                    // Fluttertoast.showToast(
                    //     msg: "Never do that Again!",
                    //     toastLength: Toast.LENGTH_SHORT,
                    //     gravity: ToastGravity.BOTTOM,
                    //     timeInSecForIosWeb: 1,
                    //     textColor: Colors.white,
                    //     fontSize: 16.0);
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuActions>(
                  value: MenuActions.logout,
                  child: Text("Log Out"),
                )
              ];
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: NotesService().getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DatabaseNote>;
                        return ListView.builder(
                          itemCount: allNotes.length,
                          itemBuilder: (context, index) {
                            final note = allNotes[index];
                            return ListTile(
                              title: Text(
                                note.text,
                                maxLines: 3,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_rounded,
                                      color: Colors.black45,
                                    ),
                                    tooltip: "delete?",
                                    onPressed: () async {
                                      final shouldDelete = showDeleteDialog(context);
                                      if (await shouldDelete) {
                                        await _notesService.deleteNote(
                                            id: note.id);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.edit),
                                  )
                                ],
                              ),
                              leading: const Icon(Icons.note_add),
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    default:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                  }
                },
              );
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
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
        onPressed: () async {
          Navigator.pushNamed(context, WriteEditNotePage);
        },
        label: const Text(
          "Note",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 20,
          ),
        ),
        icon: const Icon(
          Icons.create,
          color: Colors.black54,
          size: 30,
        ),
        extendedPadding: const EdgeInsets.all(25),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "home",
            tooltip: "home",
            activeIcon: Icon(
              Icons.home_filled,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_input_composite_outlined),
            label: "tweaks",
            tooltip: "tweaks",
            activeIcon: Icon(
              Icons.settings_input_composite_rounded,
            ),
          ),
        ],
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        key: const Key("Cool"),
      ),
    );
  }
}
