class Note {

  int _id;
  String _title;
  String _description;
  String _date;
  int _priority;

  Note(this._title, this._date, this._priority, [this._description]);

  Note.withId(this._id, this._title, this._date, this._priority, [this._description]);

  int get priority => _priority;

  set priority(int newPriority) {
    if (newPriority >=1 && newPriority <=2) {
      this._priority = newPriority;
    }
  }

  String get date => _date;

  set date(String newDate) {
    this._date = newDate;
  }

  String get description => _description;

  set description(String newDescription) {
    if (newDescription.length <= 255) {
      this._description = newDescription;
    }
  }

  String get title => _title;

  set title(String newTitle) {
    if (newTitle.length <= 255) {
      this._title = newTitle;
    }
  }

  int get id => _id;

  //Convert note object into map object
  Map<String, dynamic> toMap() {

    var map = Map<String, dynamic>();
    if ( id  != null){
      map['id'] = _id;
    }

    map['title'] = _title;
    map['description'] = _description;
    map['priority'] = _priority;
    map['date'] = _date;

    return map;
  }
  // Extract a note object from a Map Object
  Note.fromMapObject(Map<String, dynamic> map) {
   this._id = map['id'];
   this._title = map['title'];
   this._description = map['description'];
   this._priority = map['priority'];
   this._date = map['date'];
  }
}