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

Future<Map> getFromGoogleBooks(Book book) async {
  final response = await http.get("https://www.googleapis.com/books/v1/volumes?q=isbn:${book.isbn}");
  final json = JSON.decode(response.body);

  return json;
}

Future<String> checkOut(Book book) async {
  final response = await http.post("${config.hostname}/books/byIsbn/${book.isbn}/checkOutFor/${config.username}");
  if (response.statusCode == 200) {
    return "Successfully checked out ${book.title}!";
  } else {
    return "Couldn't check out ${book.title}: ${response.reasonPhrase}!";
  }
}