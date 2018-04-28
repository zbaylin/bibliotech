import 'dart:convert';

//This specifies all the fields for a single book object
class Book {
  final int isbn;
  final String dewey;
  final String title;
  final String author;
  final String publisher;
  final int edition;
  final List reservedBy;
  final int numLeft;

  Book.fromJson(Map jsonMap)
  : isbn = jsonMap['isbn'],
    dewey = jsonMap['dewey'],
    title = jsonMap['title'],
    author = jsonMap['author'],
    publisher = jsonMap['publisher'],
    edition = jsonMap['edition'],
    numLeft = jsonMap['left'],
    reservedBy =  JSON.decode(jsonMap['reserved_by']);
}