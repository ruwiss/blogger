import 'dart:async';
import 'package:blogmanname/constants/colors.dart';
import 'package:blogmanname/extensions/datetime_extensions.dart';
import 'package:blogmanname/locator.dart';
import 'package:blogmanname/models/post_model.dart';
import 'package:blogmanname/services/blogger_service.dart';
import 'package:blogmanname/viewmodels/blog_v_model.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:provider/provider.dart';
import 'package:html/parser.dart' show parse;
import '../services/ads_service.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  final _htmlController = HtmlEditorController();
  final _titleController = TextEditingController();
  final _tagController = TextEditingController();
  String? _schedule;
  bool _scheduleEnabled = false;
  bool _commentsEnabled = true;
  DateTime? _willPopDateTime;

  SnackBar _snackbar(String text) => SnackBar(
      content: Text(text == "posts"
          ? "Post Updated"
          : text == "pages"
              ? "Page Updated"
              : "Draft Updated"),
      duration: const Duration(seconds: 2));

  Future<bool> _onWillPop() async {
    final currentDateTime = DateTime.now();
    if (_willPopDateTime == null ||
        currentDateTime.difference(_willPopDateTime!) >
            const Duration(seconds: 2)) {
      _willPopDateTime = currentDateTime;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Press again to exit"),
        duration: Duration(seconds: 1),
      ));
      return false;
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      _willPopDateTime = null;
      return true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as Map;
    final content = arg['content'] as Items;
    return SafeArea(
        child: WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(content.title, style: GoogleFonts.poppins(fontSize: 15)),
          actions: [
            IconButton(
                onPressed: () => _showEditDialog(content, arg),
                icon: const Icon(Icons.mode_edit)),
            Consumer<BlogViewModel>(
              builder: (context, viewModel, child) => Row(
                children: [
                  if (arg['type'] == "draft" || content.status == "SCHEDULED")
                    IconButton(
                        onPressed: () {
                          arg['type'] == "draft";
                          if (!viewModel.isLoading) {
                            _htmlController.getText().then((value) {
                              content.content = value;
                              locator.get<BloggerService>().saveContent(
                                    context: context,
                                    items: content,
                                    commentsEnabled: _commentsEnabled,
                                    onSuccess: (type) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(_snackbar(type));
                                    },
                                  );
                            });
                          }
                        },
                        icon: Icon(
                            viewModel.isLoading
                                ? Icons.donut_large
                                : Icons.save,
                            color: KColors.teal)),
                  if (content.status != "SCHEDULED")
                    IconButton(
                        onPressed: () {
                          if (!viewModel.isLoading) {
                            arg['type'] = content.selfLink.contains("/posts")
                                ? "posts"
                                : content.selfLink.contains("/pages")
                                    ? "pages"
                                    : "draft";
                            _htmlController.getText().then(
                              (value) {
                                content.content = value;
                                locator.get<BloggerService>().publishContent(
                                      context: context,
                                      items: content,
                                      dateTime: _schedule,
                                      commentsEnabled: _commentsEnabled,
                                      onSuccess: (type) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(_snackbar(type));
                                      },
                                    );
                              },
                            );
                          }
                        },
                        icon: Icon(
                            viewModel.isLoading
                                ? Icons.workspaces_outline
                                : Icons.send_rounded,
                            color: KColors.teal)),
                ],
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              HtmlEditor(
                controller: _htmlController,
                callbacks: Callbacks(
                  onInit: () {
                    final document = parse(content.content);
                    _htmlController.insertHtml(document.outerHtml.trim());
                  },
                ),
                htmlToolbarOptions: const HtmlToolbarOptions(
                  toolbarPosition: ToolbarPosition.aboveEditor,
                  toolbarType: ToolbarType.nativeScrollable,
                  defaultToolbarButtons: [
                    StyleButtons(),
                    FontButtons(),
                    FontSettingButtons(fontSizeUnit: false),
                    ColorButtons(),
                    ListButtons(),
                    ParagraphButtons(lineHeight: false),
                    InsertButtons(),
                    OtherButtons(
                        fullscreen: false,
                        codeview: false,
                        help: false,
                        copy: false,
                        paste: false),
                  ],
                ),
                htmlEditorOptions: const HtmlEditorOptions(
                  hint: "Type a good article",
                  spellCheck: true,
                ),
                otherOptions: OtherOptions(
                    height: MediaQuery.of(context).size.height - 110),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () => _htmlController.toggleCodeView(),
            backgroundColor: Colors.grey.shade100,
            child: const Icon(Icons.code)),
      ),
    ));
  }

  Future _showEditDialog(Items singlePost, Map arg) {
    final bool isScheduled = singlePost.status == "SCHEDULED";
    _titleController.text = singlePost.title;
    _tagController.text =
        singlePost.labels != null ? singlePost.labels!.join(",") : "";
    String scheduleText = "Schedule";
    if (isScheduled) {
      _scheduleEnabled = true;
      _schedule = singlePost.published;
      final date = DateTime.parse(_schedule!);
      scheduleText = date.formatDate(true);
    }
    if (singlePost.readerComments != null) {
      _commentsEnabled = singlePost.readerComments == "ALLOW";
    }

    void saveDateTime() {
      if (_schedule != null) {
        locator.get<BloggerService>().convertToScheduled(
            context: context, items: singlePost, dateTime: _schedule);
      }
    }

    final content = arg['content'] as Items;
    final bool isPage = content.selfLink.contains("/pages");
    return showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Edit ${isPage ? "Page" : "Post"}"),
                    if (singlePost.status != "DRAFT")
                      TextButton(
                          onPressed: () {
                            locator.get<BloggerService>().revertContent(
                                  context: context,
                                  items: content,
                                  onSuccess: (type) {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(_snackbar(type));
                                  },
                                );
                          },
                          child: const Text("Convert to Draft"))
                  ],
                ),
                scrollable: true,
                actionsAlignment: MainAxisAlignment.spaceEvenly,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _customTextField(
                        title: "Title",
                        borderColor: KColors.bloggerColor,
                        controller: _titleController),
                    const SizedBox(height: 4),
                    if (!isPage)
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: _customTextField(
                                borderColor: KColors.teal,
                                controller: _tagController,
                                hint: "Tag1, tag2"),
                          ),
                          if ((arg['type'] == 'draft' ||
                                  singlePost.status == "DRAFT") &&
                              !isScheduled)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(scheduleText),
                                Switch(
                                  value: _scheduleEnabled,
                                  onChanged: (value) {
                                    setState(() {
                                      _scheduleEnabled = value;
                                      if (!value) {
                                        _schedule = null;
                                      }
                                    });
                                    saveDateTime();
                                  },
                                ),
                              ],
                            ),
                          if ((arg['type'] == 'draft' ||
                                  singlePost.status == "DRAFT") &&
                              !isScheduled)
                            DateTimePicker(
                                initialValue: '',
                                enabled: _scheduleEnabled,
                                type: DateTimePickerType.dateTimeSeparate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                                dateHintText: "Schedule",
                                dateLabelText:
                                    _schedule != null ? 'Chosen' : 'Date',
                                timeLabelText:
                                    _schedule != null ? 'Chosen' : 'Time',
                                onChanged: (value) {
                                  final date = DateTime.parse(value);
                                  _schedule = date.convertToBloggerFormat();
                                  saveDateTime();
                                },
                                validator: (_) {
                                  return null;
                                }),
                        ],
                      ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Comments"),
                        Switch(
                          value: _commentsEnabled,
                          onChanged: (value) =>
                              setState(() => _commentsEnabled = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Are you sure?"),
                              content:
                                  const Text("Your content will be deleted"),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("CANCEL")),
                                TextButton(
                                    onPressed: () async {
                                      await locator<BloggerService>()
                                          .deleteContent(context,
                                              blogId: singlePost.blog!.id,
                                              contentId: singlePost.id,
                                              isPage: isPage, onDeleted: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: const Text(
                                      "DELETE",
                                      style: TextStyle(color: Colors.red),
                                    )),
                              ],
                            ),
                          );
                        },
                        child: Text(
                          "Delete ${isPage ? 'Page' : 'POST'}",
                          style: GoogleFonts.aBeeZee(color: Colors.red),
                        ))
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("CANCEL")),
                  ElevatedButton(
                      onPressed: () {
                        singlePost.title = _titleController.text;
                        singlePost.labels = _tagController.text.isEmpty
                            ? []
                            : _tagController.text.contains(",")
                                ? _tagController.text
                                    .split(",")
                                    .map((e) => e.trim())
                                    .toList()
                                : [_tagController.text];
                        Navigator.pop(context);
                      },
                      child: const Text("SAVE")),
                ],
              ),
            ));
  }

  Container _customTextField({
    String? title,
    String? hint,
    required Color borderColor,
    required controller,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: borderColor)),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: hint,
          labelText: title,
        ),
        controller: controller,
      ),
    );
  }
}
