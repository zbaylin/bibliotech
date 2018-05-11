# <img src="/demo/icon.png?raw=true" width="64px"> bibliotech

The next generation of Library Management.

Our FBLA 2018 Mobile App Development Submission.

by Zach Baylin, Eric Miller, and Ohad Rau

- [Main Features](#main-features)
  - [User Functions](#user-functions)
    - [Checking In, Checking Out, and Reserving Books](#checking-in--checking-out--and-reserving-books)
    - [Scanning Books](#scanning-books)
    - [Searching Books](#searching-books)
    - [Social Media](#social-media)
    - [Map](#map)
    - [Google Books](#google-books)
    - [Bug Reporting](#bug-reporting)
  - [Admin Functions](#admin-functions)
    - [Customization](#customization)
    - [Administrator Interface](#administrator-interface)
      - [Book Management](#book-management)
      - [Bug/Request Management](#bug-request-management)
- [Technical Information](#technical-information)
  - [Architecture](#architecture)
    - [Model](#model)
    - [View](#view)
    - [Controller](#controller)
- [Installing](#installing)
  - [Android](#android)
  - [iOS](#ios)
    - [Testflight](#testflight)
    - [XCode](#xcode)

# Main Features

**bibliotech** was designed to meet the following requirements
- Users can:
  - check out books
  - reserve books
  - check in books
  - scan books
  - search inventory
  - request a book addition
  - interface with Twitter and other social media platforms
  - view a map of the library
  - find books on the map
  - get more information about the book from Google Books
  - report bugs
- Administrators can:
  - customize the name of the library
  - provide a custom map
  - change the checkout duration
  - from the [administrator panel](https://github.com/OhadRau/FBLA-Library-server)
    - manage the stock of inventory
    - be alerted of bug reports/book requests
    - add new books to the inventory

*\*phew\** That's a lot.

## User Functions
### Checking In, Checking Out, and Reserving Books
Checking out a book is as simple for a user as clicking its entry in the Library Book List. Here, the app will check if the user has the book, and if the book is in stock.

<img src="/demo/check_out.gif?raw=true" width="200px">


### Scanning Books
If a user has a book that they want to check in or out, they can simply use the scanning feature built into **bibliotech**. It will bring them to the same book info screen as if they simply clicked on it from the list.

<img src="/demo/scanning.gif?raw=true" width="200px">

### Searching Books
To search for a book, the user simply has to click on the search icon in the upper right corner of the main navigator. They can search the title, author, or ISBN of the book they want to find.

<img src="/demo/search.gif?raw=true" width="200px">

### Social Media
If a user wants to share that awesome book they just read from their **bibliotech**-based library, they can join the conversation on Twitter.


**bibliotech** uses the Twitter API (API keys can be found in the configuration file) to search Tweets that reference the book mentioned.


If a user taps on one of these Tweets, they will be brought to that Tweet's page in either the Twitter app (if it's installed), or the phone's default web browser.


They can also hit the **[TWEET]** button to share their own thoughts about the book, with a template Tweet being generated for them.


<img src="/demo/twitter.gif?raw=true" width="200px">

Want to share on something other than Twitter? **bibliotech**'s built in share function interfaces with all other shareable apps on your phone, such as Facebook, Snapchat, SMS, and others.

<img src="/demo/share.gif?raw=true" width="200px">

### Map
What good is a library app if the user can't find the book? **bibliotech** displays an easy to read, interactive map to the user.

<img src="/demo/view_map.gif?raw=true" width="200px">


Each individual book can also be located on the map using the **[Find On Map]** button on the book's info page.

<img src="/demo/find_on_map.gif?raw=true" width="200px">

### Google Books
**bibliotech** interfaces with one of the largest databases of books in the world: [Google Books](http://books.google.com)

On a book's info page, the user is already presented with basic information pulled from the Google Books API, such as average rating, description, etc. If the user wants to see more about the book, or purchase a copy of their own, they just have to click the **[MORE INFO]** button at the bottom of the Google Books Info panel.

<img src="/demo/google_books.gif?raw=true" width="200px">

### Bug Reporting
Even though **bibliotech** was built to be as robust as possible, bugs are still inevitable. In the event that a user finds a bug, all they have to do is use the provided bug reporting dialog found in the navigation drawer.

<img src="/demo/bug_reporting.gif?raw=true" width="200px">

## Admin Functions
### Customization
**bibliotech** was designed to be a catch-all library app. As such, it needed to be customizable to fit each libraries needs. In the `config.json` file, the administrator can specify various configuration options for the app.

**ex.**
```
{
  "school_name": "North Springs",
  "username": null,
  "hostname": "http://bibliotech.duckdns.org",
  "checkout_duration": 5,
  "twitter": {
    "consumer_secret": "random_number",
    "consumer_key": "random_number",
    "access_key": "random_number",
    "access_secret": "random_number"
  }
}
```

All of this data is serialized and kept on the users phone.

### Administrator Interface
Since all **bibliotech** instances report to a central server, we designed a user interface for the administrator to oversee the operations of the library.

You can view a demo interface [here](http://bibliotech.duckdns.org)

#### Book Management
All books and stock are the first items seen on the web interface.
Here the administrator can review the stock of books, add stock to a book, and add a book to the stock. All is done through an intuitive, easy to use HTML5 based interface.

<img src="/demo/manage_books.png?raw=true" width="350px">

#### Bug/Request Management
This is where the administrator can review bug reports and book requests. If the bug/request has been fixed or is deemed frivolous, the administrator can dismiss the report at the click of a button.

<img src="/demo/manage_bugs.png?raw=true" width="350px">

# Technical Information
**bibliotech** is written in Google's new cross-platform mobile development framework [Flutter](http://flutter.io). Flutter is written in the [Dart language](http://dartlang.org), which was also developed mostly in-house at Google.

Flutter allowed **bibliotech** to be:
- cross-platform
  - **bibliotech** works on both iOS and Android devices
- native
  - unlike other cross-platform frameworks, Flutter interfaces directly with the device's hardware, making it as fast as native languages (i.e. Swift, Kotlin)
- modular
  - Flutter apps are built using widgets. These widgets allow the developer to build a modular application with minimal reuse of code
- readable
  - Dart combines the verbose syntax of Java with the benefits of JIT languages, like Javascript. Unlike most compiled languages, Dart supports features like type inference, which allowed **bibliotech** to be built much faster
- hot reload
  - Instead of having to compile and build a new version of the app every debug update, Flutter will update the app with the changes made with sub-second refresh times. This allowed **bibliotech** to be built with unparalleled speed.

## Architecture

**bibliotech** was built using the Model-View-Controller architecure (MVC).
### Model
**bibliotech** has one main model: a book! This book also has two constructors: one from manually specifying attributes, and one that generates a book from a passed-in Map object.

```
class Book {
  final int isbn;
  final String dewey;
  final String title;
  final String author;

  ...
}
```

Books are also stored in a remote database that is controller by the [central server](https://github.com/OhadRau/FBLA-Library-server)

### View
All of the pages in **bibliotech** are built using Widgets. Some of which are custom designed. These widgets are adaptable, and will look identical relative to screen size on every device.

### Controller
In **bibliotech**, our controllers many times are built in asynchronously with the view. However, it also has some centralized route and utility code that allows it to fetch books, send bugs, etc.

**ex.**
```
Future<Map> getFromGoogleBooks(Book book) async {
  final response = await http.get("https://www.googleapis.com/books/v1/volumes?q=isbn:${book.isbn}");
  final json = JSON.decode(response.body);
  return json;
}
```

# Installing
## Android
To install on Android, you first must enable the ability to install apps from untrusted sources. You can find out how to do this [here](https://www.applivery.com/docs/troubleshooting/android-unknown-sources)

Next, follow these directions:

1. Go to the Releases page on this repository by [clicking here](https://github.com/zbaylin/bibliotech/releases).
2. Download the most recent `app-release.apk`
3. Open the file on your phone
4. Install the app

## iOS
To install on iOS, you have one of two options: TestFlight or XCode.
### Testflight
If you would like to be added as a beta tester for **bibliotech** on iOS, please complete the [sign-up survey](https://goo.gl/forms/4crRaxPMCAb2LzXe2). You will be sent an email with information on how to download and install **bibliotech** from Testflight.

### XCode
To use XCode, clone the repository on a Mac with XCode installed. Open the file `ios/Runner.xcworkspace`. Run the file in XCode, either with an iPhone or iPad plugged in, or with the iOS Simulator running.


