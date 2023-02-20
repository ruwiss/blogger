import 'dart:convert';
import 'package:blogmanname/constants/strings.dart';
import 'package:blogmanname/locator.dart';
import 'package:blogmanname/models/comments_model.dart' as commentsModel;
import 'package:blogmanname/models/views_model.dart';
import 'package:blogmanname/services/auth_service.dart';
import 'package:blogmanname/services/local_service.dart';
import 'package:blogmanname/viewmodels/blog_v_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import 'ads_service.dart';

class BloggerService {
  final _dio = Dio();

  String accessToken = "";
  String selfUrl = "";
  String postsUrl = "";

  Future fetch(
      {required String url,
      required Function(Map<String, dynamic> json) onResult}) async {
    selfUrl = url;
    final result = await _dio.get(url,
        options: Options(
            headers: KStrings.headers(accessToken),
            validateStatus: (status) => status! < 500));
    if (result.statusCode == 200) {
      onResult(result.data);
    } else if (result.statusCode == 401) {
      locator.get<AuthService>().authWithGoogle(
        onLogin: (user, newAccess) {
          accessToken = newAccess;
          fetch(url: url, onResult: onResult);
        },
      );
    }
  }

  Future fetchBlogs(String accessTOKEN,
      {required Function(Map<String, dynamic>) onResult}) async {
    accessToken = accessTOKEN;

    await fetch(
        url: "https://www.googleapis.com/blogger/v3/users/self/blogs",
        onResult: onResult);
  }

  Future _fetchBlogViews(
      {required String blogId,
      required String range,
      required Function(ViewsModel model) whenGot}) async {
    await fetch(
      url:
          "https://blogger.googleapis.com/v3/blogs/$blogId/pageviews?range=$range",
      onResult: (json) {
        whenGot(ViewsModel.fromJson(json));
      },
    );
  }

  void _fetchAgain(BuildContext context) {
    fetchPostsOrPages(context, postsUrl);
  }

  Future fetchPostsOrPages(BuildContext context, String url,
      {bool isDraft = false}) async {
    final blogViewModel = Provider.of<BlogViewModel>(context, listen: false);
    final viewModel = Provider.of<BlogViewModel>(context, listen: false);
    blogViewModel.setUserPosts({});
    Map<String, dynamic> items = {};
    Map<String, dynamic> item1 = {};
    Map<String, dynamic> item2 = {};
    blogViewModel.setIsLoading(true);
    if (isDraft) {
      await fetch(
          url: "${url.replaceFirst("/drafts", "/posts")}?status=draft",
          onResult: (json) => item1 = json);
      await fetch(
          url: "${url.replaceFirst("/drafts", "/pages")}?status=draft",
          onResult: (json) {
            item2 = json;
          });
    } else {
      await fetch(
          url: "$url?status=scheduled", onResult: (json) => item1 = json);
      await fetch(
          url: url,
          onResult: (json) {
            item2 = json;
          });
      postsUrl = url;
    }
    items = item1;
    if (items.containsKey("items")) {
      items['items'].addAll(item2.containsKey("items") ? item2['items'] : []);
    } else {
      items = item2;
    }
    viewModel.setUserPosts(items);

    blogViewModel.setIsLoading(false);
    if (url.contains("/blogs/") &&
        !url.contains("/pages") &&
        !url.contains("/drafts")) {
      final String blogId = url.split("blogs/").last.split("/").first;
      blogViewModel.setBlogViews(clear: true);
      // get blog views
      for (var range in ["7DAYS", "30DAYS", "all"]) {
        await _fetchBlogViews(
            blogId: blogId,
            range: range,
            whenGot: (model) => blogViewModel.setBlogViews(viewsModel: model));
      }
    }
    locator.get<LocalService>().checkForAppReview();
  }

  Future saveContent(
      {required BuildContext context,
      required Items items,
      required bool commentsEnabled,
      required Function(String type) onSuccess}) async {
    final Map data = {
      "content": items.content.trim(),
      "title": items.title,
    };
    if (items.labels != null) {
      data['labels'] = items.labels;
    }
    data['readerComments'] =
        commentsEnabled ? "ALLOW" : "DONT_ALLOW_HIDE_EXISTING";

    final postType = items.selfLink.contains("/pages") ? "pages" : "posts";
    final url =
        "https://blogger.googleapis.com/v3/blogs/${items.blog!.id}/$postType/${items.id}";
    final response = await _dio.put(url,
        data: jsonEncode(data),
        options: Options(
            headers: KStrings.headers(accessToken),
            validateStatus: (status) => status! < 500));

    if (response.statusCode == 401) {
      locator.get<AuthService>().authWithGoogle(
        onLogin: (user, newAccess) {
          accessToken = newAccess;
          saveContent(
              context: context,
              items: items,
              commentsEnabled: commentsEnabled,
              onSuccess: onSuccess);
        },
      );
    } else if (response.statusCode == 200) {
      _fetchAgain(context);
      onSuccess(postType);
    }
  }

  Future convertToScheduled(
      {required BuildContext context,
      required Items items,
      String? dateTime}) async {
    final Map data = {"status": dateTime != null ? "SCHEDULED" : "LIVE"};
    data['publishDate'] = dateTime;
    final postType = items.selfLink.contains("/pages") ? "pages" : "posts";
    final url =
        "https://blogger.googleapis.com/v3/blogs/${items.blog!.id}/$postType/${items.id}/publish";
    final response = await _dio.post(url,
        data: jsonEncode(data),
        options: Options(
            headers: KStrings.headers(accessToken),
            validateStatus: (status) => status! < 500));

    if (response.statusCode == 401) {
      locator.get<AuthService>().authWithGoogle(
        onLogin: (user, newAccess) {
          accessToken = newAccess;
          convertToScheduled(
              context: context, items: items, dateTime: dateTime);
        },
      );
    } else if (response.statusCode == 200) {
      _fetchAgain(context);
    }
  }

  Future publishContent(
      {required BuildContext context,
      required Items items,
      required String? dateTime,
      required bool commentsEnabled,
      required Function(String type) onSuccess}) async {
    await saveContent(
        context: context,
        items: items,
        commentsEnabled: commentsEnabled,
        onSuccess: (t) {});
    final Map data = {"status": dateTime != null ? "SCHEDULED" : "LIVE"};
    if (dateTime != null) {
      data['publishDate'] = dateTime;
    }
    final postType = items.selfLink.contains("/pages") ? "pages" : "posts";
    final url =
        "https://blogger.googleapis.com/v3/blogs/${items.blog!.id}/$postType/${items.id}/publish";

    final response = await _dio.post(url,
        data: jsonEncode(data),
        options: Options(
            headers: KStrings.headers(accessToken),
            validateStatus: (status) => status! < 500));

    if (response.statusCode == 401) {
      locator.get<AuthService>().authWithGoogle(
        onLogin: (user, newAccess) {
          accessToken = newAccess;
          publishContent(
              context: context,
              items: items,
              dateTime: dateTime,
              commentsEnabled: commentsEnabled,
              onSuccess: onSuccess);
        },
      );
    } else if (response.statusCode == 200) {
      onSuccess(postType);
      locator.get<AdService>().showInterstitialAd();
      _fetchAgain(context);
    }
  }

  Future revertContent(
      {required BuildContext context,
      required Items items,
      required Function(String type) onSuccess}) async {
    final postType = items.selfLink.contains("/pages") ? "pages" : "posts";
    final url =
        "https://blogger.googleapis.com/v3/blogs/${items.blog!.id}/$postType/${items.id}/revert";
    final response = await _dio.post(url,
        options: Options(
            headers: KStrings.headers(accessToken),
            validateStatus: (status) => status! < 500));

    if (response.statusCode == 401) {
      locator.get<AuthService>().authWithGoogle(
        onLogin: (user, newAccess) {
          accessToken = newAccess;
          revertContent(context: context, items: items, onSuccess: onSuccess);
        },
      );
    } else if (response.statusCode == 200) {
      onSuccess(postType);
      locator.get<AdService>().showInterstitialAd();
      _fetchAgain(context);
    }
  }

  Future createEmptyDraft(BuildContext context, String blogId,
      {required bool isPage, required Function(Items items) onCreate}) async {
    final viewModel = Provider.of<BlogViewModel>(context, listen: false);
    viewModel.setIsNewPostCreating(true);
    final url =
        "https://blogger.googleapis.com/v3/blogs/$blogId/${isPage ? 'pages' : 'posts'}";

    final options = Options(
        headers: KStrings.headers(accessToken),
        validateStatus: (status) => status! < 500);

    final response = await _dio.post(url, options: options);
    if (response.statusCode == 200) {
      final Items items = Items.fromJson(response.data);
      await _dio.post("$url/${items.id}/revert", options: options);
      onCreate(items);
    } else if (response.statusCode == 401) {
      locator.get<AuthService>().authWithGoogle(
        onLogin: (user, newAccess) {
          accessToken = newAccess;
          createEmptyDraft(context, blogId,
              isPage: isPage, onCreate: (items) => onCreate(items));
        },
      );
    }
    viewModel.setIsNewPostCreating(false);
  }

  Future deleteContent(BuildContext context,
      {required String blogId,
      required String contentId,
      required bool isPage,
      required Function() onDeleted}) async {
    final viewModel = Provider.of<BlogViewModel>(context, listen: false);
    final url =
        "https://blogger.googleapis.com/v3/blogs/$blogId/${isPage ? 'pages' : 'posts'}/$contentId";
    await _dio.delete(url,
        options: Options(headers: KStrings.headers(accessToken)));

    viewModel.removeItem(contentId);
    onDeleted();
  }

  Future<List<commentsModel.Items>> getComments(String selfLink) async {
    final response = await _dio.get(selfLink,
        options: Options(
            headers: KStrings.headers(accessToken),
            validateStatus: (status) => status! < 500));
    if (response.statusCode == 200) {
      return commentsModel.CommentsModel.fromJson(response.data).items;
    } else if (response.statusCode == 401) {
      late List<commentsModel.Items> list;
      await locator.get<AuthService>().authWithGoogle(
        onLogin: (user, newAccess) async {
          accessToken = newAccess;
          list = await getComments(selfLink);
        },
      );
      return list;
    } else {
      return [];
    }
  }

  Future removeComment(String selfLink) async {
    final response = await _dio.delete(selfLink,
        options: Options(
            headers: KStrings.headers(accessToken),
            validateStatus: (status) => status! < 500));
    if (response.statusCode == 401) {
      await locator.get<AuthService>().authWithGoogle(
        onLogin: (user, newAccess) async {
          removeComment(selfLink);
        },
      );
    }
  }
}
