import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/note.dart';
import 'note_edit_screen.dart';

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {

  final ApiService api = ApiService();
  List<Note> notes = [];

  @override
  void initState(){
    super.initState();
    loadNotes();
  }

  loadNotes() async {

    var data = await api.getNotes();

    setState(() {
      notes = data.map<Note>((n)=>Note.fromJson(n)).toList();
    });

  }

  Widget noteCard(Note note){

    return GestureDetector(

      onTap: () async {

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NoteEditScreen(note: note),
          ),
        );

        loadNotes();
      },

      child: Container(

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.yellow[100],
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12,blurRadius:5)
          ]
        ),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              note.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize:16
              ),
            ),

            const SizedBox(height:8),

            Expanded(
              child: Text(
                note.content,
                overflow: TextOverflow.fade,
              ),
            )

          ],

        ),

      ),

    );

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(
        title: const Text("Notes"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: GridView.builder(

          itemCount: notes.length,

          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:2,
            crossAxisSpacing:12,
            mainAxisSpacing:12,
          ),

          itemBuilder:(context,index){
            return noteCard(notes[index]);
          },

        ),

      ),

      floatingActionButton: FloatingActionButton(

        child: const Icon(Icons.add),

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

  }

}