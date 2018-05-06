# bibliotech

The next generation of Library Management.

Our FBLA 2018 Mobile App Development Submission.

by Zach Baylin, Eric Miller, and Ohad Rau

- [Main Features](#main-features)
  - [User Functions](#user-functions)
    - [Checking In, Out and Reserving Books](#checking-in-out-and-reserving-books)
    - [Scanning Books](#scanning-books)
    - [Searching Books](#searching-books)
    - [Social Media](#social-media)
# Main Features

**bibliotech** was designed to meet the following requirements
- users can:
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
- adminsitrators can:
  - customize the name of the library
  - provide a custom map
  - change the checkout duration
  - from the [administrator panel](https://github.com/OhadRau/FBLA-Library-server)
    - manage the stock of inventory
    - be alerted of bug reports/book requests
    - add new books to the inventory
    - manage users

*\*phew\** That's a lot.

## User Functions
### Checking In, Out and Reserving Books
Checking out a book is as simple for a user as clicking its entry in the Library Book List. Here, the app will check if the user has the book, and if the book is in stock.

<img src="/demo/check_out.gif?raw=true" width="200px">


### Scanning Books
If a user has a book that they want to check in or out, they can simply use the scanning feature built into **bibliotech**. It will bring them to the same book info screen as if they simply clicked on it from the list.

<img src="/demo/scanning.gif?raw=true" width="200px">

### Searching Books
To search for a book, the user simply has to click on the search icon in the upper right corner of the main navigator. They can search the title, author, or ISBN of the book they want to find.

### Social Media
If a user wants to share that awesome book they just read from their **bibliotech**-based library, they can join the conversation on Twitter.


**bibliotech** uses the Twitter API (API keys can be found in the configuration file) to search Tweets that reference the book mentioned.


If a use taps on one of these Tweets, they will be brought to that Tweet's page in either the Twitter app (if it's installed), or the phone's default web browser.


They can also hit the **[TWEET]** button to share their own thoughts about the book, with a template Tweet being generated for them.


<img src="/demo/twitter.gif?raw=true" width="200px">

### Map
What good is a library app if the user can't find the book? **bibliotech** displays and easy to read, interactive map to the user.

Each individual book can also be located on the map using the **[Find On Map]** button on the book's info page.