import 'package:http/http.dart' as http;
import 'package:bibliotech/models/book.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:bibliotech/config.dart' as config;
import 'package:bibliotech/utils/config.dart';
import 'package:bibliotech/utils/twitter.dart';

main() async {
  config.hostname = "http://bibliotech.duckdns.org";
  final Book book = await getBook("9780060803964");
  var googleBook = await getFromTwitter(book);
  print(googleBook);
}

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

Future<Stream<Book>> getAllMyBooks() async {
  var client = new http.Client();
  var uri = Uri.parse("${config.hostname}/user/${config.username}/checked_out");
  var request = new http.Request('get', uri);

  var response = await client.send(request);

  return response.stream
    .transform(UTF8.decoder)
    .transform(JSON.decoder)
    .expand((jsonBody) => (jsonBody as Map)['checked_out'])
    // Takes every JSON element in the Map returned from the response
    // and iterates over it. This is useful because it creates a new Map
    // that is in memory, and we don't have to continously parse JSON,
    // which is heavily resource intensive.
    .map((jsonBook) {
      return new Book.fromJson(jsonBook);
    });
}

Future<Stream<Book>> getBooksWithDewey(int range) async {
  var client = new http.Client();
  var uri = Uri.parse("${config.hostname}/books/byDewey/$range");
  var request = new http.Request('get', uri);

  var response = await client.send(request);

  return response.stream
    .transform(UTF8.decoder)
    .transform(JSON.decoder)
    .expand((jsonBody) => (jsonBody as Map)['books'])
    .map((jsonBook) => new Book.fromJson(jsonBook));
}

Future<Map> getFromGoogleBooks(Book book) async {
  final response = await http.get("https://www.googleapis.com/books/v1/volumes?q=isbn:${book.isbn}");
  final json = JSON.decode(response.body);
  return json;
}

Future<Map> getFromGoogleBooksByISBN(String isbn) async {
  final response = await http.get("https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn");
  final json = JSON.decode(response.body);
  return json;
}

Future<List> getFromTwitter(Book book) async {
  TwitterApi twitter = new TwitterApi(config.twitter['consumer_key'], config.twitter['consumer_secret'], config.twitter['access_key'], config.twitter['access_secret']);
  final response = await twitter.search(book);
  final json = JSON.decode(response);
  return json['statuses'];
}

Future<bool> doIHave(Book book) async {
  final response = await http.get("${config.hostname}/user/${config.username}/has/${book.isbn}");
  final json = JSON.decode(response.body);
  return json['has'];
}

Future<Map> checkOut(Book book) async {
  final response = await http.post("${config.hostname}/books/byIsbn/${book.isbn}/checkOutFor/${config.username}");
  if (response.statusCode == 200) {
    return {'success': true, 'message': "Successfully checked out ${book.title}!"};
  } else {
    return {'success': true, 'message': "Couldn't check out ${book.title}: ${response.reasonPhrase}!"};
  }
}

Future<Map> checkIn(Book book) async {
  final response = await http.post("${config.hostname}/books/byIsbn/${book.isbn}/checkInFor/${config.username}");
  if (response.statusCode == 200) {
    return {'success': true, 'message': "Successfully checked in ${book.title}!"};
  } else {
    return {'success': false, 'message': "Couldn't check in ${book.title}: ${response.reasonPhrase}!"};
  }
}

Future<Map> reserve(Book book) async {
  final response = await http.post("${config.hostname}/books/byIsbn/${book.isbn}/reserveFor/${config.username}");
  if (response.statusCode == 200) {
    return {'success': true, 'message':"Successfully reserved ${book.title}!"};
  } else {
    return {'success': false, 'message': "Couldn't reserve ${book.title}: ${response.reasonPhrase}!"};
  }
}

Future<Book> getBook(String isbn) async {
  final response = await http.get("${config.hostname}/books/byIsbn/$isbn");
  final json = JSON.decode(response.body);
  if (json == null) {
    return null;
  } else {
    return new Book.fromJson(json);
  }
}