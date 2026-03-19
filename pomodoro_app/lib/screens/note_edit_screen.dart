import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/note.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class NoteEditScreen extends StatefulWidget {
  final Note? note;

  NoteEditScreen({this.note});

  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final ApiService api = ApiService();
  late TextEditingController title;
  late TextEditingController content;

  @override
  void initState() {
    super.initState();
    title = TextEditingController(
      text: widget.note?.title ?? "",
    );
    content = TextEditingController(
      text: widget.note?.content ?? "",
    );
  }

  Future<void> save() async {
    if (widget.note == null) {
      await api.createNote(
        title.text,
        content.text,
      );
    } else {
      await api.updateNote(
        widget.note!.id,
        title.text,
        content.text,
      );
    }
    Navigator.pop(context);
  }

  Future<void> delete() async {
    await api.deleteNote(widget.note!.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.getThemeData();
        final colors = theme.colorScheme;
        final buttonText = colors.onPrimary;

        // Màu AppBar chỉ đậm hơn một chút so với nền background (clean, không quá nổi)
        final appBarColor = colors.background.withOpacity(0.95);
        final appBarTextColor = colors.onBackground.withOpacity(0.88);

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            title: Text(
              widget.note == null ? "New Note" : "Edit Note",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: appBarTextColor,
                fontSize: 17,
              ),
            ),
            backgroundColor: appBarColor,
            elevation: 1,
            shadowColor: Colors.black.withOpacity(0.08),
            actions: [
              if (widget.note != null)
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: colors.primary.withOpacity(0.7),
                  ),
                  onPressed: delete,
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              children: [
                // Title field
                TextField(
                  controller: title,
                  decoration: InputDecoration(
                    labelText: "Title",
                    hintText: "Enter note title",
                    labelStyle: TextStyle(
                      color: colors.onSurface.withOpacity(0.7),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: colors.primary.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: colors.primary.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: colors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Content field – BORDER NHẸ, MÀU THEME
                Expanded(
                  child: TextField(
                    controller: content,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      labelText: "Content",
                      hintText: "Write your note here...",
                      labelStyle: TextStyle(
                        color: colors.onSurface.withOpacity(0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: colors.primary.withOpacity(0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: colors.primary.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: colors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                const SizedBox(height: 16),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: buttonText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: save,
                    child: const Text(
                      "Save",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
