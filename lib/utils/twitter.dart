import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bibliotech/models/book.dart';
import 'package:crypto/crypto.dart';

const String twitterApiBaseUrl = "https://api.twitter.com/1.1/";

class TwitterApi {
  final String consumerKey, consumerKeySecret, accessToken, accessTokenSecret;
  Hmac _sigHasher;
  final DateTime _epochUtc = new DateTime(1970, 1, 1);

  // TwitterApi class adapted from DanTup:
  // https://blog.dantup.com/2017/01/simplest-dart-code-to-post-a-tweet-using-oauth/

  TwitterApi(this.consumerKey, this.consumerKeySecret, this.accessToken,
      this.accessTokenSecret) {
    var bytes = UTF8.encode("$consumerKeySecret&$accessTokenSecret");
    _sigHasher = new Hmac(sha1, bytes);
  }

  /// Sends a tweet with the supplied text and returns the response from the Twitter API.
  Future<String> tweet(String text) {
    var data = {"status": text, "trim_user": "1"};

    return _callApi("POST", "statuses/update.json", data);
  }

  Future<String> search(Book book) {
    var data = {"q": book.title + " " + book.author};
    
    return _callApi("GET", "search/tweets.json", data);
  }

  Future<String> _callApi(String method, String url, Map<String, String> data) {
    // Build the form data (exclude OAuth stuff that's already in the header).
    var formData = _filterMap(data, (k) => !k.startsWith("oauth_"));

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

    if (method == "GET")
      return _getRequest(fullUrl, oAuthHeader);
    else if (method == "POST")
      return _sendRequest(fullUrl, oAuthHeader, _toQueryString(formData));
  }

  /// Generate an OAuth signature from OAuth header values.
  String _generateSignature(String method, String url, Map<String, String> data) {
    var sigString = _toQueryString(data);
    var fullSigData = "$method&${_encode(url)}&${_encode(sigString)}";

    return BASE64.encode(_hash(fullSigData));
  }

  /// Generate the raw OAuth HTML header from the values (including signature).
  String _generateOAuthHeader(Map<String, String> data) {
    var oauthHeaderValues = _filterMap(data, (k) => k.startsWith("oauth_"));

    return "OAuth " + _toOAuthHeader(oauthHeaderValues);
  }

  Future<String> _getRequest(Uri url, String oAuthHeader) async {
    final http = new HttpClient();
    final request = await http.getUrl(url);
    request.headers
      ..contentType = new ContentType("application", "x-www-form-urlencoded",
          charset: "utf-8")
      ..add("Authorization", oAuthHeader);
    print("**************\n" + url.toString() + "\n" + request.headers.toString() + "\n***************");
    final response = await request.close().whenComplete(http.close);
    return response.transform(UTF8.decoder).join("");
  }

  /// Send HTTP Request and return the response.
  Future<String> _sendRequest(
      Uri fullUrl, String oAuthHeader, String body) async {
    final http = new HttpClient();
    final request = await http.postUrl(fullUrl);
    request.headers
      ..contentType = new ContentType("application", "x-www-form-urlencoded",
          charset: "utf-8")
      ..add("Authorization", oAuthHeader);
    request.write(body);
    final response = await request.close().whenComplete(http.close);
    return response.transform(UTF8.decoder).join("");
  }

  Map<String, String> _filterMap(
      Map<String, String> map, bool test(String key)) {
    return new Map.fromIterable(map.keys.where(test), value: (k) => map[k]);
  }

  String _toQueryString(Map<String, String> data) {
    var items = data.keys.map((k) => "$k=${_encode(data[k])}").toList();
    items.sort();

    return items.join("&");
  }

  String _toOAuthHeader(Map<String, String> data) {
    var items = data.keys.map((k) => "$k=\"${_encode(data[k])}\"").toList();
    items.sort();

    return items.join(", ");
  }

  List<int> _hash(String data) => _sigHasher.convert(data.codeUnits).bytes;

  String _encode(String data) => Uri.encodeComponent(data);

}