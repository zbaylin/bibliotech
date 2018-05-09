library bibliotech.config;

// This is a method to include global config variables
// e.g. a bool "isLoggedIn" could be referenced globally as config.isLoggedIn
// Inspired by Ruby's $vars

// The API key for the library server
String apiKey;
// The name of the school to show in the app
String schoolName;
// The URL for the library server
String hostname;
// The username to check out books for
String username;
// The amount of time a book is allowed to be checked out for before it's overdue
int checkoutDuration;
// The Twitter API keys
Map twitter;