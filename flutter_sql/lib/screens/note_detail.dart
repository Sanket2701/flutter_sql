import 'package:flutter/material.dart';
import 'package:fluttersql/models/note.dart';
import 'package:fluttersql/utils/database_helper.dart';
import 'package:intl/intl.dart';
import 'dart:async';

// ignore: must_be_immutable
class NoteDetail extends StatefulWidget {

  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  _NoteDetailState createState() => _NoteDetailState(this.note, this.appBarTitle);
}

class _NoteDetailState extends State<NoteDetail> {

  static var _priorities = ['High', 'Low'];

  DatabaseHelper databaseHelper = DatabaseHelper();

  String appBarTitle;
  Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  _NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme
        .of(context)
        .textTheme
        .subtitle1;
    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(

      // ignore: missing_return
      onWillPop: () {
        moveToLastScreen();
      },

      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              moveToLastScreen();
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: ListView(
            children: <Widget>[
              ListTile(
                title: DropdownButton(
                    items: _priorities.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    }).toList(),
                    style: textStyle,
                    value: updatePriorityAsString(note.priority),
                    onChanged: (valueSelectedByUser) {
                      setState(() {
                        print('User selected $valueSelectedByUser');
                        updatePriorityAsInt(valueSelectedByUser);
                      });
                    }
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: titleController,
                  style: textStyle,
                  onChanged: (value) {
                    print('Something in Title text');
                    updateTitle();
                  },
                  decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)
                      )
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: descriptionController,
                  style: textStyle,
                  onChanged: (value) {
                    print('Something in Description text');
                    updateDescription();
                  },
                  decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)
                      )
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        color: Theme
                            .of(context)
                            .primaryColorDark,
                        textColor: Theme
                            .of(context)
                            .primaryColorLight,
                        child: Text(
                          'Save',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            print('Save Button Clicked');
                            _save();
                          });
                        },
                      ),
                    ),
                    Container(width: 5.0),
                    Expanded(
                      child: RaisedButton(
                        color: Theme
                            .of(context)
                            .primaryColorDark,
                        textColor: Theme
                            .of(context)
                            .primaryColorLight,
                        child: Text(
                          'Delete',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            print('Delete Button Clicked');
                            _delete();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Convert the string priority in the form of integer before saving it to database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  // Convert the int priority in the form of string and show it to user
  String updatePriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; // 'High'
        break;
      case 2:
        priority = _priorities[1]; // 'Low'
        break;
    }
    return priority;
  }

  // Update the title of Note object
  void updateTitle() {
    note.title = titleController.text;
  }
  // Update the description of Note object
  void updateDescription() {
    note.description = descriptionController.text;
  }
  // Save data to database
  void _save() async {

    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) { // update operation
      result = await databaseHelper.updateNote(note);
    }else { // insert operation
      result = await databaseHelper.insertNote(note);
    }
    if (result != 0){
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      _showAlertDialog('Status', 'Problem Saving Note');
    }

  }

  void _delete() async {

    moveToLastScreen();
    // Case 1 : If user is trying to delete the new note
    // i.e he has came to detail page by pressing the fab of NoteList page
    if (note.id != null){
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }
    // Case 2: User is trying to delete the existing note
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0){
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occurred while Deleting Note');
    }
  }

  void _showAlertDialog(String title, String message) {

    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
      context: context,
      builder: (_) => alertDialog
    );
  }
}