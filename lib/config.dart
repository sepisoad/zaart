// =============================================================================
// Children type

class Children {
  String name;
  bool published;
  DateTime date;
  String author;
  List<String> tags;

  Children()
      : name = '',
        published = false,
        date = DateTime.now(),
        author = 'UNKNOWN',
        tags = <String>[];

  Children.fromJson(Map<String, dynamic> json) {
    this.name = json['name'];
    this.published = json['published'];
    this.date = DateTime.parse(json['date']);
    this.author = json['author'];
    this.tags = json['tags'].map<String>((s) => s as String).toList();
  }

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

class Section {
  String name;
  List<Children> children;

  Section()
      : name = '',
        children = <Children>[];

  Section.fromJson(Map<String, dynamic> json) {
    this.name = json['name'];
    this.children = json['children'].map<Children>((c) {
      return Children.fromJson(c as Map<String, dynamic>);
    }).toList();
  }

  Map<String, dynamic> toJson() => {
        'name': this.name,
        'children': this.children.map((c) => c.toJson()).toList()
      };
}

// =============================================================================
// Config type

class Config {
  String author;
  String name;
  List<Section> sections;

  Config()
      : author = "",
        name = "",
        sections = null;

  Config.fromJson(Map<String, dynamic> json) {
    this.author = json['author'];
    this.name = json['name'];
    this.sections = json['sections'].map<Section>((s) {
      // var section = s as Map<String, dynamic>;
      // return Section.fromJson(section);
      return Section.fromJson(s as Map<String, dynamic>);
    }).toList();
  }

  Map<String, dynamic> toJson() => {
        'author': this.author,
        'name': this.name,
        'sections': this.sections.map((s) => s.toJson()).toList()
      };
}
