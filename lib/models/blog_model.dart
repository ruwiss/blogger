class UserBlogs {
  List<Items>? items;
  String? kind;

  UserBlogs({this.items, this.kind});

  UserBlogs.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    kind = json['kind'];
  }
}

class Items {
  late String status;
  late String kind;
  late String description;
  late String url;
  Posts? posts;
  late String updated;
  Posts? pages;
  Locale? locale;
  late String published;
  late String id;
  late String selfLink;
  late String name;

  Items(
      {required this.status,
      required this.kind,
      required this.description,
      required this.url,
      this.posts,
      required this.updated,
      this.pages,
      this.locale,
      required this.published,
      required this.id,
      required this.selfLink,
      required this.name});

  Items.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    kind = json['kind'];
    description = json['description'];
    url = json['url'];
    posts = json['posts'] != null ? Posts.fromJson(json['posts']) : null;
    updated = json['updated'];
    pages = json['pages'] != null ? Posts.fromJson(json['pages']) : null;
    locale = json['locale'] != null ? Locale.fromJson(json['locale']) : null;
    published = json['published'];
    id = json['id'];
    selfLink = json['selfLink'];
    name = json['name'];
  }
}

class Posts {
  late int totalItems;
  late String selfLink;

  Posts({required this.totalItems, required this.selfLink});

  Posts.fromJson(Map<String, dynamic> json) {
    totalItems = json['totalItems'];
    selfLink = json['selfLink'];
  }
}

class Locale {
  late String country;
  late String variant;
  late String language;

  Locale(
      {required this.country, required this.variant, required this.language});

  Locale.fromJson(Map<String, dynamic> json) {
    country = json['country'];
    variant = json['variant'];
    language = json['language'];
  }
}
