// =============================================================================
// Children type
/// A class that represents section children
class Children {
  String name;
  bool published;
  DateTime date;
  String author;
  List<String> tags;

  /// default constructor
  Children()
      : name = '',
        published = false,
        date = DateTime.now(),
        author = 'UNKNOWN',
        tags = <String>[];

  /// json constructor
  /// [json] is a `Map` with a `String` key and `dynamic` value
  Children.fromJson(Map<String, dynamic> json) {
    this.name = json['name'];
    this.published = json['published'];
    this.date = DateTime.parse(json['date']);
    this.author = json['author'];
    this.tags = json['tags'].map<String>((s) => s as String).toList();
  }

  /// converts object to `json`
  Map<String, dynamic> toJson() => {
        'name': this.name,
        'published': this.published,
        'date': this.date.toString(),
        'author': this.author,
        'tags': tags
      };
}

// =============================================================================
// Section type
/// A class that represents sections
class Section {
  String name;
  List<Children> children;

  /// default constructor
  Section()
      : name = '',
        children = <Children>[];

  /// json constructor
  /// [json] is a `Map` with a `String` key and `dynamic` value
  Section.fromJson(Map<String, dynamic> json) {
    this.name = json['name'];
    this.children = json['children'].map<Children>((c) {
      return Children.fromJson(c as Map<String, dynamic>);
    }).toList();
  }

  /// converts object to `json`
  Map<String, dynamic> toJson() => {
        'name': this.name,
        'children': this.children.map((c) => c.toJson()).toList()
      };
}

// =============================================================================
// Config type
/// A class that represents configuration
class Config {
  String author;
  String name;
  List<Section> sections;

  /// default constructor
  Config()
      : author = "",
        name = "",
        sections = null;

  /// json constructor
  /// [json] is a `Map` with a `String` key and `dynamic` value
  Config.fromJson(Map<String, dynamic> json) {
    this.author = json['author'];
    this.name = json['name'];
    this.sections = json['sections'].map<Section>((s) {
      // var section = s as Map<String, dynamic>;
      // return Section.fromJson(section);
      return Section.fromJson(s as Map<String, dynamic>);
    }).toList();
  }

  /// converts object to `json`
  Map<String, dynamic> toJson() => {
        'author': this.author,
        'name': this.name,
        'sections': this.sections.map((s) => s.toJson()).toList()
      };
}
