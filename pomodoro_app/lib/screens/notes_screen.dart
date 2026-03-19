import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/note.dart';
import 'note_edit_screen.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final ApiService api = ApiService();
  List<Note> notes = [];
  int candidateOldIndex = -1;

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    var data = await api.getNotes();
    setState(() {
      notes = data.map<Note>((n) => Note.fromJson(n)).toList();
    });
  }

  void rearrangeNotes(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final movedItem = notes.removeAt(oldIndex);
    notes.insert(newIndex, movedItem);
    setState(() {});
  }

  Widget stickyNoteCard({
    required Note note,
    required Color noteBackgroundColor,
    required Color noteForegroundColor,
    required Color accentColor,
  }) {
    const scale = 1.04;

    return Draggable<int>(
      data: notes.indexOf(note),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoteEditScreen(note: note),
            ),
          );
          loadNotes();
        },
        child: Transform.scale(
          scale: scale,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: noteBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: noteForegroundColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    note.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: noteForegroundColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        color: noteBackgroundColor.withOpacity(0.95),
        child: SizedBox(
          width: 160,
          height: 120,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: noteForegroundColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  note.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: noteForegroundColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      childWhenDragging: Container(color: Colors.transparent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.getThemeData();
        final colorScheme = theme.colorScheme;

        final noteBackgroundColor = colorScheme.surface.withOpacity(0.95);
        final noteForegroundColor = colorScheme.onSurface;
        final accentColor = colorScheme.primary;

        // Màu App bar chỉ đậm hơn một chút so với background
        final headerColor =
            colorScheme.background.withOpacity(0.9); // sát màu nền nhưng đậm hơn tí
        final headerTextColor = colorScheme.onSurface.withOpacity(0.85);

        return Scaffold(
          backgroundColor: colorScheme.background,
          appBar: AppBar(
            title: Text(
              "Notes",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: headerTextColor,
                fontSize: 17,
              ),
            ),
            backgroundColor: headerColor,
            elevation: 1, // rất nhẹ
            shadowColor: Colors.black.withOpacity(0.08),
          ),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: notes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.note, size: 48, color: accentColor),
                        const SizedBox(height: 16),
                        Text(
                          "No notes yet",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : DragTarget<int>(
                    builder: (context, candidateData, rejectedData) {
                      return GridView.builder(
                        itemCount: notes.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.0,
                        ),
                        itemBuilder: (context, index) {
                          return stickyNoteCard(
                            note: notes[index],
                            noteBackgroundColor: noteBackgroundColor,
                            noteForegroundColor: noteForegroundColor,
                            accentColor: accentColor,
                          );
                        },
                      );
                    },
                    onAccept: (int newIndex) {
                      if (candidateOldIndex != -1 && candidateOldIndex != newIndex) {
                        rearrangeNotes(candidateOldIndex, newIndex);
                      }
                    },
                    onWillAccept: (index) {
                      candidateOldIndex = index!;
                      return true;
                    },
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: accentColor,
            child: Icon(
              Icons.add,
              color: colorScheme.onPrimary,
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoteEditScreen(),
                ),
              );
              loadNotes();
            },
          ),
        );
      },
    );
  }
}
