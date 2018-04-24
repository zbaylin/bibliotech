import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:bibliotech/config.dart' as config;
import 'package:bibliotech/pages/bookList.dart';
import 'package:bibliotech/utils/user.dart' as user;
import 'package:bibliotech/pages/scan.dart';
import 'package:bibliotech/pages/map.dart';


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

  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: searchBar.build(context),
      body: new PageView(
        children: [
          bookList,
          map,
          shelf
        ],
        // Specify the page controller
        controller: _pageController,
        onPageChanged: onPageChanged
      ),
      bottomNavigationBar: new BottomNavigationBar(
        items: [
          new BottomNavigationBarItem(
              icon: new Icon(Icons.book),
              title: new Text("My Library")
          ),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.map),
              title: new Text("Map")
          ),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.reorder),
              title: new Text("My Shelf")
          )
        ],

        /// Will be used to scroll to the next page
        /// using the _pageController
        onTap: navigationTapped,
        currentIndex: _page
      )
    );
  }

  // Called when the user presses on of the
  // [BottomNavigationBarItem] with corresponding
  // page index
  void navigationTapped(int page){

    // Animating to the page.
    _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease
    );
  }


  void onPageChanged(int page){
    setState((){
      this._page = page;
    });
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
        body: new BookList(BookListType.SEARCH, searchTerm: search,),
      ))),
      buildDefaultAppBar: buildAppBar
    );
    bookList = new BookList(BookListType.LIBRARY);
    map = new LibraryMap();
    shelf = new BookList(BookListType.SHELF);
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
        new PopupMenuButton<MenuAction>(
          onSelected: (MenuAction result) {
            switch (result) {
              case MenuAction.LogOut:
                user.logOut();
                Navigator.of(context).pushReplacementNamed('/LogInPage');
                break;
              case MenuAction.Scan:
                Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new Scan()));
                break;
              default:
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<MenuAction>(
              value: MenuAction.LogOut,
              child: const Text("Log Out"),
            ),
            const PopupMenuItem<MenuAction>(
              value: MenuAction.Scan,
              child: const Text("Scan"),
            )
          ]
        )
      ],
    );
  }
  

}