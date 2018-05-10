import 'package:http/http.dart' as http;
import 'package:bibliotech/models/book.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:bibliotech/config.dart' as config;
import 'package:bibliotech/utils/twitter.dart'; 

main() async {
  config.hostname = "http://bibliotech.duckdns.org";
  final Book book = await getBook("9780060803964");
  var googleBook = await getFromTwitter(book);
  print(googleBook);
}

//Retrieves a sequence of books in the library 
Future<Stream<Book>> getAllBooks() async {
  var client = new http.Client();
  var uri = Uri.parse(config.hostname + "/books");
  var request = new http.Request('get', uri);

  var response = await client.send(request);

  return response.stream
    .transform(UTF8.decoder)
    .transform(JSON.decoder)
    .expand((jsonBody) => (jsonBody as Map)['books'])
    .map((jsonBook) => new Book.fromJson(jsonBook));
}

//Function for searching for a book
//Implemented in the top-right corner of the main screen (Book List)
Future<Stream<Book>> searchAllBooks(String searchTerm) async {
  var client = new http.Client();
  var uri = Uri.parse(config.hostname + "/books/search/$searchTerm");
  var request = new http.Request('get', uri);

  var response = await client.send(request);

  return response.stream
    .transform(UTF8.decoder)
    .transform(JSON.decoder)
    .expand((jsonBody) => (jsonBody as Map)['books'])
    .map((jsonBook) => new Book.fromJson(jsonBook));
}

//Retrieves the sequence of books on the user's shelf
Future<Stream<Book>> getAllMyBooks() async {
  var client = new http.Client();
  var uri = Uri.parse("${config.hostname}/user/${config.username}/checked_out");
  var request = new http.Request('get', uri);

  var response = await client.send(request);

  return response.stream
    .transform(UTF8.decoder)
    .transform(JSON.decoder)
    .expand((jsonBody) => (jsonBody as Map)['checked_out'])
    // Future<Stream<Book>>.asyncMap maps over the stream with a function that returns a Future<Book> and
    // merges all the futures to return a Future<Stream<Book>> instead of a Future<Stream<Future<Book>>.
    // This is equivalent to folding over the stream with .then() after each Future<Book> in the stream.
    // Basically, this function allows us to request additional details about the book from the API before
    // returning the stream of books to the user. This allows us to construct the full Book object from
    // and endpoint that only returns the ISBN (but not the title, author, etc.).
    .map((jsonBook) {
      return new Book.fromJson(jsonBook);
    });
}

//Retrieves a sequence of books that are in the Dewey Decimal range
//Implemented on the Map page, via the "View Books" button
Future<Stream<Book>> getBooksWithDewey(int range) async {
  var client = new http.Client();
  var uri = Uri.parse("${config.hostname}/books/byDewey/$range");
  var request = new http.Request('get', uri);

  var response = await client.send(request);

  return response.stream
    .transform(UTF8.decoder)
    .transform(JSON.decoder)
    .expand((jsonBody) => (jsonBody as Map)['books'])
    .asyncMap((jsonBook) async {
      final response = await http.get("${config.hostname}/books/byIsbn/${(jsonBook as Map)['isbn']}");
      final json = JSON.decode(response.body);
      return new Book.fromJson(json);
    });
}

//Retrieves the information for a Book from Google Books
Future<Map> getFromGoogleBooks(Book book) async {
  final response = await http.get("https://www.googleapis.com/books/v1/volumes?q=isbn:${book.isbn}");
  final json = JSON.decode(response.body);
  
  return json;
}

//Finds a book on Google Books by the ISBN number
Future<Map> getFromGoogleBooksByISBN(String isbn) async {
  final response = await http.get("https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn");
  final json = JSON.decode(response.body);
  return json;
}

//Searches for instances of the book's title and author on Twitter
//Implemented at the bottom of the Book Info panel
Future<List> getFromTwitter(Book book) async {
  TwitterApi twitter = new TwitterApi(config.twitter['consumer_key'], config.twitter['consumer_secret'], config.twitter['access_key'], config.twitter['access_secret']);
  final response = await twitter.search(book);
  final json = JSON.decode(response);
  return json['statuses'];
}

//Returns true if the user has checked out the given book
Future<bool> doIHave(Book book) async {
  final response = await http.get("${config.hostname}/user/${config.username}/has/${book.isbn}");
  final json = JSON.decode(response.body);
  return json['has'];
}

//Calls an http post request to check out a book for the user
Future<Map> checkOut(Book book) async {
  final response = await http.post("${config.hostname}/books/byIsbn/${book.isbn}/checkOutFor/${config.username}");
  if (response.statusCode == 200) {
    return {'success': true, 'message': "Successfully checked out ${book.title}!"};
  } else {
    return {'success': true, 'message': "Couldn't check out ${book.title}: ${response.reasonPhrase}!"};
  }
}

//Calls an http post request to return a book from the user's shelf
Future<Map> checkIn(Book book) async {
  final response = await http.post("${config.hostname}/books/byIsbn/${book.isbn}/checkInFor/${config.username}");
  if (response.statusCode == 200) {
    return {'success': true, 'message': "Successfully checked in ${book.title}!"};
  } else {
    return {'success': false, 'message': "Couldn't check in ${book.title}: ${response.reasonPhrase}!"};
  }
}

//Reserves a book that is out of stock in the library
//Once the book is back in stock, it will be added to the user's shelf
Future<Map> reserve(Book book) async {
  final response = await http.post("${config.hostname}/books/byIsbn/${book.isbn}/reserveFor/${config.username}");
  if (response.statusCode == 200) {
    return {'success': true, 'message':"Successfully reserved ${book.title}!"};
  } else {
    return {'success': false, 'message': "Couldn't reserve ${book.title}: ${response.reasonPhrase}!"};
  }
}

//Returns a book based on the ISBN
//Implemented when a user scans a barcode
Future<Book> getBook(String isbn) async {
  final response = await http.get("${config.hostname}/books/byIsbn/$isbn");
  final json = JSON.decode(response.body);
  if (json == null) {
    return null;
  } else {
    print(response.body);
    return new Book.fromJson(json);
  }
}