import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:womens_courtyard/personal_file.dart';
import 'edit_personal_file.dart' as edit_personal_page;

/// A file in charge of searching a personal file.
/// While searching, the app helps with suggestions of personal files that match
/// the current text in the search bar.
/// When a suggestion is pressed, it leads the user to the personal file
/// selected.

class PersonalFileSearchPage extends StatefulWidget {
  PersonalFileSearchPage({Key? key, this.username = ''}) : super(key: key);

  final String username;

  @override
  _PersonalFileSearchPageState createState() =>
      new _PersonalFileSearchPageState();
}

/// This function brings every personal file from the database (for a fast
/// search).

class _PersonalFileSearchPageState extends State<PersonalFileSearchPage> {
  TextEditingController controller = new TextEditingController();

  // Get json result and convert it to model. Then add
  Future<Null> getUserDetails() async {
    try {
      _personalFiles = [];
      final response =
          await FirebaseFirestore.instance.collection('clients').get();
      _personalFiles = [];
      for (final doc in response.docs) {
        _personalFiles.add(PersonalFile.fromDoc(doc));
      }
      _personalFiles.sort((a, b) => a.firstName.compareTo(b.firstName));
      setState(() {});
    } catch (e) {
      print('caught $e');
    }
  }

  @override
  void initState() {
    super.initState();

    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: new Scaffold(
        appBar: new AppBar(title: Text('חיפוש תיק אישי')),
        body: new Column(
          children: <Widget>[
            new Container(
              color: Theme.of(context).primaryColor,
              child: new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Card(
                  child: new ListTile(
                    leading: new Icon(Icons.search),
                    title: new TextField(
                      controller: controller,
                      decoration: new InputDecoration(
                          hintText: 'חיפוש', border: InputBorder.none),
                      onChanged: onSearchTextChanged,
                    ),
                    trailing: new IconButton(
                      icon: new Icon(Icons.cancel),
                      onPressed: () {
                        controller.clear();
                        onSearchTextChanged('');
                      },
                    ),
                  ),
                ),
              ),
            ),
            new Expanded(
                child: _searchResult.length != 0 || controller.text.isNotEmpty
                    ? FileList(list: _searchResult, username: widget.username)
                    : FileList(
                        list: _personalFiles, username: widget.username)),
          ],
        ),
      ),
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    _personalFiles.forEach((personalFile) {
      if (personalFile.idNo.toString().contains(text) ||
          personalFile.firstName.contains(text) ||
          personalFile.lastName.contains(text) ||
          (personalFile.firstName + ' ' + personalFile.lastName).contains(text))
        _searchResult.add(personalFile);
    });
    _personalFiles.sort((a, b) => a.firstName.compareTo(b.firstName));
    setState(() {});
  }
}

/// This class builds us the list like structure of the page.

class FileList extends StatelessWidget {
  final List<PersonalFile> list;
  FileList({required this.list, required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      // Search query results
      itemCount: list.length,
      itemBuilder: (context, index) {
        return new Card(
          child: new ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          edit_personal_page.PersonalFileEditPage(
                              username: this.username, person: list[index])));
            },
            leading: Icon(Icons.folder),
            title: new Text(list[index].firstName + ' ' + list[index].lastName),
            subtitle: new Text('תעודת זהות: ' + list[index].idNo.toString()),
          ),
          margin: const EdgeInsets.all(0.0),
        );
      },
    );
  }
}

List<PersonalFile> _searchResult = [];

List<PersonalFile> _personalFiles = [];
