class CommentsModel {
  late List<Items> items;

  CommentsModel({required this.items});

  CommentsModel.fromJson(Map<String, dynamic> json) {
    items = <Items>[];
    json['items'].forEach((v) {
      items.add(Items.fromJson(v));
    });
  }
}

class Items {
  late String content;
  late String kind;
  Author? author;
  late String updated;
  late Blog blog;
  late String published;
  late Blog post;
  late String id;
  late String selfLink;

  Items(
      {required this.content,
      required this.kind,
      this.author,
      required this.updated,
      required this.blog,
      required this.published,
      required this.post,
      required this.id,
      required this.selfLink});

  Items.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    kind = json['kind'];
    author = json['author'] != null ? Author.fromJson(json['author']) : null;
    updated = json['updated'];
    blog = Blog.fromJson(json['blog']);
    published = json['published'];
    post = Blog.fromJson(json['post']);
    id = json['id'];
    selfLink = json['selfLink'];
  }
}

class Author {
  String? url;
  Image? image;
  String? displayName;
  String? id;

  Author({this.url, this.image, this.displayName, this.id});

  Author.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    image = json['image'] != null ? Image.fromJson(json['image']) : null;
    displayName = json['displayName'];
    id = json['id'];
  }
}

class Image {
  late String url;
  Image({required this.url});
  Image.fromJson(Map<String, dynamic> json) {
    url = "http:${json['url']}";
  }
}

class Blog {
  late String id;
  Blog({required this.id});

  Blog.fromJson(Map<String, dynamic> json) {
    id = json['id'];
  }
}
