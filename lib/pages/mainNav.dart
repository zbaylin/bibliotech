import 'package:flutter/material.dart';
import 'package:bibliotech/config.dart' as config;
import 'package:bibliotech/pages/bookList.dart';

class MainNav extends StatefulWidget {
  @override
  MainNavState createState() {
    return new MainNavState();
  }
}

class MainNavState extends State<MainNav> {
  // This controller can be used to programmatically set the current displayed page
  PageController _pageController;

  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Bibliotech: ${config.schoolName}"),
      ),
      body: new PageView(
        children: [
          new BookList(),
          new Container(color: Colors.blue),
          new Container(color: Colors.grey)
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
  }

  @override
  void dispose(){
    super.dispose();
    _pageController.dispose();
  }

}