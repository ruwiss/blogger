class PostModel {
  List<Items>? items;
  String? kind;
  String? etag;

  PostModel({this.items, this.kind, this.etag});

  PostModel.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    kind = json['kind'];
    etag = json['etag'];
  }
}

class Items {
  String? status;
  late String content;
  late String kind;
  List<String>? labels;
  late String title;
  late String url;
  Author? author;
  late String updated;
  late Replies replies;
  Blog? blog;
  late String etag;
  late String published;
  late String id;
  late String selfLink;
  String? readerComments;

  Items(
      {required this.content,
      required this.kind,
      this.labels,
      this.status,
      this.readerComments,
      required this.title,
      required this.url,
      this.author,
      required this.updated,
      required this.replies,
      this.blog,
      required this.etag,
      required this.published,
      required this.id,
      required this.selfLink});

  Items.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    content = json['content'];
    readerComments = json['readerComments'];
    kind = json['kind'];
    labels = json['labels'] != null
        ? (json['labels'] as List).map((e) => e.toString()).toList()
        : null;
    title = json['title'];
    url = json['url'];
    author = json['author'] != null ? Author.fromJson(json['author']) : null;
    updated = json['updated'];
    replies = json['replies'] != null
        ? Replies.fromJson(json['replies'])
        : Replies(totalItems: "0", selfLink: "");
    blog = json['blog'] != null ? Blog.fromJson(json['blog']) : null;
    etag = json['etag'];
    published = json['published'];
    id = json['id'];
    selfLink = json['selfLink'];
  }
}

class Author {
  late String url;
  Image? image;
  late String displayName;
  late String id;

  Author(
      {required this.url,
      this.image,
      required this.displayName,
      required this.id});

  Author.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    image = json['image'] != null ? Image.fromJson(json['image']) : null;
    displayName = json['displayName'];
    id = json['id'];
  }
}

class Image {
  String? url;

  Image({this.url});

  Image.fromJson(Map<String, dynamic> json) {
    url = json['url'];
  }
}

class Replies {
  late String totalItems;
  late String selfLink;

  Replies({required this.totalItems, required this.selfLink});

  Replies.fromJson(Map<String, dynamic> json) {
    totalItems = json['totalItems'] ?? "0";
    selfLink = json['selfLink'] ?? "";
  }
}

class Blog {
  late String id;

  Blog({required this.id});

  Blog.fromJson(Map<String, dynamic> json) {
    id = json['id'];
  }
}
