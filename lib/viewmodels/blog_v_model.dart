import 'package:blogmanname/models/blog_model.dart' as blog;
import 'package:blogmanname/models/post_model.dart';
import 'package:blogmanname/models/views_model.dart';
import 'package:flutter/foundation.dart';

class BlogViewModel with ChangeNotifier {
  blog.UserBlogs? userBlogs;
  var blogViews = <ViewsModel>[];
  Map<String, String> selectedBlog = {};
  PostModel? userPosts;
  bool isLoading = true;

  bool isNewPostCreating = false;

  void setUserBlogs(Map<String, dynamic> blogsJson) {
    userBlogs = blog.UserBlogs.fromJson(blogsJson);
    notifyListeners();
  }

  void setBlogViews({ViewsModel? viewsModel, bool clear = false}) {
    if (viewsModel != null) {
      blogViews.add(viewsModel);
    } else if (clear) {
      blogViews.clear();
    }

    notifyListeners();
  }

  void setUserPosts(Map<String, dynamic> postsJson) {
    if (postsJson.isEmpty) {
      userPosts = null;
    } else {
      userPosts = PostModel.fromJson(postsJson);
    }
    notifyListeners();
  }

  void setSelectedBlog(Map<String, String> data) {
    selectedBlog = data;
    notifyListeners();
  }

  void setIsLoading(bool l) {
    isLoading = l;
    notifyListeners();
  }

  void setIsNewPostCreating(bool b) {
    isNewPostCreating = b;
    notifyListeners();
  }

  void removeItem(String contentId) {
    userPosts!.items!.removeWhere((element) => element.id == contentId);
    notifyListeners();
  }
}
