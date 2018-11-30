// =============================================================================
// Page type
/// A class that represents sections
class Page {
  String name;
  bool published;
  DateTime date;
  String layout;
  String author;
  List<String> tags = [];
  List<Page> children = [];

  /// default constructor
  Page(
      {this.name,
      this.published = false,
      this.date = null,
      this.layout,
      this.author,
      this.tags,
      this.children});

  /// json constructor
  /// [json] is a `Map` with a `String` key and `dynamic` value
  Page.fromJson(Map<String, dynamic> json) {
    this.name = json['name'];
    this.published = json['published'];
    this.date = json['date'] == null ? null : DateTime.parse(json['date']);
    this.layout = json['layout'];
    this.author = json['author'];
    this.tags = json['tags'].map<String>((s) => s as String).toList();
    this.children = json['children'].map<Page>((c) {
      return Page.fromJson(c as Map<String, dynamic>);
    }).toList();
  }

  /// converts object to `json`
  Map<String, dynamic> toJson() => {
        'name': this.name,
        'published': this.published,
        'date': this.date == null ? null : this.date.toString(),
        'layout': this.layout,
        'author': this.author,
        'tags': this.tags,
        'children': this.children.map((c) => c.toJson()).toList()
      };
}

// =============================================================================
// Config type
/// A class that represents configuration
class Config {
  String author;
  String title;
  String theme;
  List<Page> pages = [];

  /// default constructor
  Config({this.title, this.author, this.theme, this.pages});

  /// json constructor
  /// [json] is a `Map` with a `String` key and `dynamic` value
  Config.fromJson(Map<String, dynamic> json) {
    this.author = json['author'];
    this.title = json['title'];
    this.theme = json['theme'];
    this.pages = json['pages'].map<Page>((s) {
      return Page.fromJson(s as Map<String, dynamic>);
    }).toList();
  }

  /// converts object to `json`
  Map<String, dynamic> toJson() => {
        'author': this.author,
        'title': this.title,
        'theme': this.theme,
        'pages': this.pages.map((s) => s.toJson()).toList()
      };
}
