


import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullScreenImageView extends StatefulWidget {
  final String imageUrl;
  final VoidCallback onBookmark;
  final bool isBookmarked;

  FullScreenImageView({
    required this.imageUrl,
    required this.onBookmark,
    required this.isBookmarked,
  });

  @override
  _FullScreenImageViewState createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.isBookmarked;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () {
           
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
              widget.onBookmark(); 
            },
          ),
        ],
      ),
      body: PhotoViewGallery.builder(
        itemCount: 1,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(widget.imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(color: Colors.black),
        pageController: PageController(),
      ),
    );
  }
}
