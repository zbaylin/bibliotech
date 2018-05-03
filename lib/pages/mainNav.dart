import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:bibliotech/config.dart' as config;
import 'package:bibliotech/pages/bookList.dart';
import 'package:bibliotech/utils/user.dart' as user;
import 'package:bibliotech/utils/scan.dart' as scanner;
import 'package:bibliotech/pages/map.dart';
import 'package:bibliotech/routes/bugs.dart';
import 'package:flutter/services.dart';

class MainNav extends StatefulWidget {
  @override
  MainNavState createState() {
    
    return new MainNavState();
    
  }
}


enum MenuAction {LogOut, Scan}
class MainNavState extends State<MainNav> {
  // This controller can be used to programmatically set the current displayed page
  PageController _pageController;

  SearchBar searchBar;
  BookList bookList;
  LibraryMap map;
  BookList shelf;

  TextEditingController bugController = new TextEditingController();

  Widget _currentPage;
  
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return new Scaffold(
      appBar: searchBar.build(context),
      drawer: new Drawer(
        child: new ListView (
          children: <Widget>[
            new UserAccountsDrawerHeader (
              accountName: new Text("${config.username}"),
              currentAccountPicture: new CircleAvatar(
                child: new Text(config.username[0]),
              ),
              accountEmail: new Text("${config.schoolName}"),
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage('assets/acct-background.jpg'),
                  fit: BoxFit.fill
                )
              ),
            ),
            new ListTile(
              title: new Text("Library"),
              trailing: new Icon(Icons.book),
              onTap: () {
                setState(() => _currentPage = bookList);
                Navigator.of(context).pop();
              },
            ),
            new ListTile(
              title: new Text("Map"),
              trailing: new Icon(Icons.map),
              onTap: () {
                setState(() => _currentPage = map);
                Navigator.of(context).pop();
              },
            ),
            new ListTile(
              title: new Text("My Shelf"),
              trailing: new Icon(Icons.reorder),
              onTap: () {
                setState(() => _currentPage = shelf);
                Navigator.of(context).pop();
              },
            ),
            new ListTile(
              title: new Text("Scan a Barcode"),
              trailing: new Icon(Icons.filter_center_focus),
              onTap: () async => await scanner.scan(context)
            ),
            new Divider(),
            new ListTile(
              title: new Text("Report a Bug"),
              trailing: new Icon(Icons.bug_report),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => new AlertDialog(
                    title: new Text("Bug Report"),
                    content: new Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new Text("Please let us know what happened and what you were doing at the time of the bug."),
                        new TextField(
                          controller: bugController,
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      new FlatButton( 
                        child: new Text("SUBMIT"),
                        onPressed: () async { 
                          await submitBugReport(bugController.text);
                          bugController.clear();
                          Navigator.of(context).pop();
                        }
                      )
                    ],
                  )
                );
              },
            ),
            new ListTile(
              title: new Text("Log Out"),
              trailing: new Icon(Icons.exit_to_app),
              onTap: () => logOut()
            ),
          ]
        )
      ),
      body: _currentPage
    );
  }

  void logOut(){
    user.logOut();
    Navigator.of(context).pushReplacementNamed('/LogInPage');
  }

  @override
  void initState() {
    super.initState();
    _pageController = new PageController();
    searchBar = new SearchBar(
      inBar: false,
      setState: setState,
      onSubmitted: (search) => Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new Scaffold(
        appBar: new AppBar(
          title: new Text("Search: $search"),
        ),
        body: (search.isNotEmpty
        ? new BookList(BookListType.SEARCH, searchTerm: search,)
        // Fixes bug that shows error screen when the user searches an empty string
        : new BookList(BookListType.LIBRARY)),
      ))),
      buildDefaultAppBar: buildAppBar
    );
    bookList = new BookList(BookListType.LIBRARY);
    map = new LibraryMap(LibraryMapType.ALL);
    shelf = new BookList(BookListType.SHELF);
    _currentPage = bookList;
  }

  @override
  void dispose(){
    super.dispose();
    _pageController.dispose();
  }

  AppBar buildAppBar(context) {
    return new AppBar(
      title: new Text("Bibliotech: ${config.schoolName}"),
      actions: <Widget>[
        searchBar.getSearchAction(context),
      ],
    );
  }
}