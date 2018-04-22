import 'package:http/http.dart' as http;
import 'package:bibliotech/models/book.dart';
import 'dart:async';
import 'dart:convert';
import 'package:bibliotech/config.dart' as config;

main() async {
  config.hostname = "http://localhost:9292";
  var books = await getAllBooks();
  books.listen((book) => print(book.isbn));
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
    .asyncMap((jsonBook) async {
      final response = await http.get("${config.hostname}/books/byIsbn/${(jsonBook as Map)['isbn']}");
      final json = JSON.decode(response.body);
      return new Book.fromJson(json);
    });
}

Future<Map> getFromGoogleBooks(Book book) async {
  final response = await http.get("https://www.googleapis.com/books/v1/volumes?q=isbn:${book.isbn}");
  final json = JSON.decode(response.body);

  return json;
}

Future<bool> doIHave(Book book) async {
  final response = await http.get("${config.hostname}/user/${config.username}/has/${book.isbn}");
  final json = JSON.decode(response.body);
  return json['has'];
}

Future<String> checkOut(Book book) async {
  final response = await http.post("${config.hostname}/books/byIsbn/${book.isbn}/checkOutFor/${config.username}");
  if (response.statusCode == 200) {
    return "Successfully checked out ${book.title}!";
  } else {
    return "Couldn't check out ${book.title}: ${response.reasonPhrase}!";
  }
}

Future<String> checkIn(Book book) async {
  final response = await http.post("${config.hostname}/books/byIsbn/${book.isbn}/checkInFor/${config.username}");
  if (response.statusCode == 200) {
    return "Successfully checked in ${book.title}!";
  } else {
    return "Couldn't check in ${book.title}: ${response.reasonPhrase}!";
  }
}

Future<String> reserve(Book book) async {
  final response = await http.post("${config.hostname}/books/byIsbn/${book.isbn}/reserveFor/${config.username}");
  if (response.statusCode == 200) {
    return "Successfully reserved ${book.title}!";
  } else {
    return "Couldn't reserve ${book.title}: ${response.reasonPhrase}!";
  }
}

Future<Book> getBook(String isbn) async {
  final response = await http.get("${config.hostname}/books/byIsbn/$isbn");
  final json = JSON.decode(response.body);

  return new Book.fromJson(json);
}