import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/note.dart';

class NoteEditScreen extends StatefulWidget {

  final Note? note;

  NoteEditScreen({this.note});

  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen>{

  final ApiService api = ApiService();

  late TextEditingController title;
  late TextEditingController content;

  @override
  void initState(){

    super.initState();

    title = TextEditingController(
      text: widget.note?.title ?? ""
    );

    content = TextEditingController(
      text: widget.note?.content ?? ""
    );

  }

  save() async {

    if(widget.note == null){

      await api.createNote(
        title.text,
        content.text
      );

    } else {

      await api.updateNote(
        widget.note!.id,
        title.text,
        content.text
      );

    }

    Navigator.pop(context);

  }

  delete() async {

    await api.deleteNote(widget.note!.id);

    Navigator.pop(context);

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(

        title: Text(widget.note == null ? "New Note" : "Edit Note"),

        actions: [

          if(widget.note != null)

          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: delete,
          )

        ],

      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(

              controller: title,

              decoration: const InputDecoration(
                labelText: "Title"
              ),

            ),

            const SizedBox(height:16),

            Expanded(

              child: TextField(

                controller: content,
                maxLines: null,
                expands: true,

                decoration: const InputDecoration(
                  labelText: "Content",
                  border: OutlineInputBorder()
                ),

              ),

            ),

            const SizedBox(height:20),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(
                onPressed: save,
                child: const Text("Save"),
              ),

            )

          ],

        ),

      ),

    );

  }

}