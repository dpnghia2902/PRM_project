const Note = require("../models/Note");

/// CREATE NOTE
exports.createNote = async (req, res) => {
  try {

    const { title, content } = req.body;

    const note = await Note.create({
      userId: req.user.id,
      title,
      content
    });

    res.json(note);

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

/// GET NOTES
exports.getNotes = async (req, res) => {
  try {

    const notes = await Note.find({
      userId: req.user.id
    }).sort({ createdAt: -1 });

    res.json(notes);

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

/// UPDATE NOTE
exports.updateNote = async (req, res) => {
  try {

    const { title, content } = req.body;

    const note = await Note.findByIdAndUpdate(
      req.params.id,
      { title, content },
      { new: true }
    );

    res.json(note);

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

/// DELETE NOTE
exports.deleteNote = async (req, res) => {
  try {

    await Note.findByIdAndDelete(req.params.id);

    res.json({ message: "Note deleted" });

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};