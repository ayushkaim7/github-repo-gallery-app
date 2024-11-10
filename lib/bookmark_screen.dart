import 'dart:math';

import 'package:assignment/full_screen_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class BookmarkScreen extends StatefulWidget {
  final List<Map<String, dynamic>> bookmarks;
  final Function(Map<String, dynamic>) onBookmark;

  BookmarkScreen({required this.bookmarks, required this.onBookmark});

  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  late List<Map<String, dynamic>> _bookmarks;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _bookmarks = List.from(widget.bookmarks);
  }

  void _removeBookmark(Map<String, dynamic> bookmark) {
    widget.onBookmark(bookmark);
    setState(() {
      _bookmarks.removeWhere((item) => item['url'] == bookmark['url']);
    });
  }


  double _getRandomHeight() {
    return _random.nextDouble() * (3 - 2) + 2; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bookmarked Images"),
        elevation: 0,
      ),
      body: _bookmarks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No bookmarks yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                itemCount: _bookmarks.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageView(
                            imageUrl: _bookmarks[index]['fullUrl'],
                            onBookmark: () => _removeBookmark(_bookmarks[index]),
                            isBookmarked: true,
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _bookmarks[index]['url'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.5),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.remove_circle,
                                color: Colors.white,
                                size: 20,
                              ),
                              padding: EdgeInsets.all(4),
                              constraints: BoxConstraints(),
                              onPressed: () => _removeBookmark(_bookmarks[index]),
                            ),
                          ),
                        ),
                    
                        if (_bookmarks[index]['owner'] != null)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.7),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              padding: EdgeInsets.all(8),
                              child: Text(
                                _bookmarks[index]['owner'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}