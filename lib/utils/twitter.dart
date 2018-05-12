import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bibliotech/models/book.dart';
import 'package:crypto/crypto.dart';

// The endpoint to use when calling the API (version 1.1)
const String twitterApiBaseUrl = "https://api.twitter.com/1.1/";

// TwitterApi class adapted from DanTup:
// https://blog.dantup.com/2017/01/simplest-dart-code-to-post-a-tweet-using-oauth/

class TwitterApi {
  final String consumerKey, consumerKeySecret, accessToken, accessTokenSecret;
  Hmac _sigHasher;
  // Set up the UNIX epoch time as the basis for all time data
  final DateTime _epochUtc = new DateTime(1970, 1, 1);

  
  // Set up the crypto for OAuth from the Twitter OAuth details in the config file
  TwitterApi(this.consumerKey, this.consumerKeySecret, this.accessToken,
      this.accessTokenSecret) {
    var bytes = UTF8.encode("$consumerKeySecret&$accessTokenSecret");
    _sigHasher = new Hmac(sha1, bytes);
  }

  // Searches a book and its author on Twitter
  Future<String> search(Book book) {
    // Add ?q="$book.title $book.author" to the GET parameters
    var data = {"q": book.title + " " + book.author};
    
    // Make the call to the Twitter API
    return _callApi("GET", "search/tweets.json", data);
  }

  // Make a POST or GET API call to the Twitter API using OAuth
  Future<String> _callApi(String method, String url, Map<String, String> data) {
    // Build the form data (exclude OAuth stuff that's already in the header).
    var formData = _filterMap(data, (k) => !k.startsWith("oauth_"));

    // If sending a GET request, the URI includes the GET parameters as a query string
    var fullUrl = Uri.parse(method == "POST"
     ? twitterApiBaseUrl + url
     : twitterApiBaseUrl + url + "?" + _toQueryString(formData));

    // Timestamps are in seconds since 1/1/1970.
    var timestamp = new DateTime.now().toUtc().difference(_epochUtc).inSeconds;

    // Add all the OAuth headers we'll need to use when constructing the hash.
    data["oauth_consumer_key"] = consumerKey;
    data["oauth_signature_method"] = "HMAC-SHA1";
    data["oauth_timestamp"] = timestamp.toString();
    data["oauth_nonce"] = "kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg"; // Required, but Twitter doesn't appear to use it
    data["oauth_token"] = accessToken;
    data["oauth_version"] = "1.0";

    // Generate the OAuth signature and add it to our payload.
    data["oauth_signature"] = _generateSignature(method, twitterApiBaseUrl + url, data);

    // Build the OAuth HTTP Header from the data.
    var oAuthHeader = _generateOAuthHeader(data);

    // Make the actual call with all the data that we've set up
    if (method == "GET")
      return _getRequest(fullUrl, oAuthHeader);
    else if (method == "POST")
      return _sendRequest(fullUrl, oAuthHeader, _toQueryString(formData));
  }

  // Generate an OAuth signature from OAuth header values to allow the server to
  // verify that the request hasn't been edited
  String _generateSignature(String method, String url, Map<String, String> data) {
    var sigString = _toQueryString(data);
    // Must specify what method (POST or GET) you're using in the signature
    var fullSigData = "$method&${_encode(url)}&${_encode(sigString)}";

    return BASE64.encode(_hash(fullSigData));
  }

  // Generate the raw OAuth HTML header from the values (including signature)
  // to be used as the authentication field of the HTTP request
  String _generateOAuthHeader(Map<String, String> data) {
    // Include only the oauth_* header values
    var oauthHeaderValues = _filterMap(data, (k) => k.startsWith("oauth_"));

    return "OAuth " + _toOAuthHeader(oauthHeaderValues);
  }

  // Send a GET request over HTTP and return the response
  Future<String> _getRequest(Uri url, String oAuthHeader) async {
    final http = new HttpClient();
    final request = await http.getUrl(url);
    // Set up the header to connect to OAuth
    request.headers
      ..contentType = new ContentType("application", "x-www-form-urlencoded",
          charset: "utf-8")
      ..add("Authorization", oAuthHeader);
    final response = await request.close().whenComplete(http.close);
    // Convert the response to a string
    return response.transform(UTF8.decoder).join("");
  }

  // Send HTTP POST request and return the response.
  Future<String> _sendRequest(
      Uri fullUrl, String oAuthHeader, String body) async {
    final http = new HttpClient();
    final request = await http.postUrl(fullUrl);
    // Set up the header to connect to OAuth
    request.headers
      ..contentType = new ContentType("application", "x-www-form-urlencoded",
          charset: "utf-8")
      ..add("Authorization", oAuthHeader);
    // Add in the body (POST parameters)
    request.write(body);
    final response = await request.close().whenComplete(http.close);
    // Convert the response to a string
    return response.transform(UTF8.decoder).join("");
  }

  // Map and filter a list (update or remove all items in a list)
  Map<String, String> _filterMap(
      Map<String, String> map, bool test(String key)) {
    return new Map.fromIterable(map.keys.where(test), value: (k) => map[k]);
  }

  // Convert a list of parameters into an HTTP parameter list (a=b&c=d&e=f...)
  String _toQueryString(Map<String, String> data) {
    // Percent encode each item
    var items = data.keys.map((k) => "$k=${_encode(data[k])}").toList();
    // Sort them (required to work with OAuth)
    items.sort();

    // Join all the items into a single string delimited by ampersands
    return items.join("&");
  }

  // Convert a list of parameters into an OAuth parameter list (a=b, c=d, e=f...)
  String _toOAuthHeader(Map<String, String> data) {
    // Percent encode each item
    var items = data.keys.map((k) => "$k=\"${_encode(data[k])}\"").toList();
    // Sort them (required to work with OAuth)
    items.sort();

    // Join all the items into a single string delimited by commas
    return items.join(", ");
  }

  // Hash a string and return it as a byte list
  List<int> _hash(String data) => _sigHasher.convert(data.codeUnits).bytes;

  // Percent-encode a string (e.g. " " -> "%20")
  String _encode(String data) => Uri.encodeComponent(data);
}