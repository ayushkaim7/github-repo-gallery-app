import 'dart:convert';
import 'dart:math';
import 'package:assignment/bookmark_screen.dart';
import 'package:assignment/full_screen_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';

const accessKey =
    'yy9icbUiDZwv3LMN6nmprn962hQosRVy4cLvnuqwVRQ'; 

Future<List<Map<String, dynamic>>> fetchPhotos() async {
  final url = Uri.parse(
      'https://api.unsplash.com/photos/random?client_id=$accessKey&count=10');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List;
    return data
        .map((photo) => {
              'url': photo['urls']['small'],
              'fullUrl': photo['urls']['regular'],
              'owner': photo['user']['name'],
              'ownerProfileUrl': photo['user']['portfolio_url'] ?? '#',
              'ownerImage': photo['user']['profile_image']['medium']
            })
        .toList();
  } else {
    throw Exception('Failed to load photos');
  }
}

class UnsplashGallery extends StatefulWidget {
  @override
  _UnsplashGalleryState createState() => _UnsplashGalleryState();
}

class _UnsplashGalleryState extends State<UnsplashGallery> {
  late Future<List<Map<String, dynamic>>> photoData;
  List<Map<String, dynamic>> bookmarks = [];

  @override
  void initState() {
    super.initState();
    photoData = fetchPhotos();
    _loadBookmarks();
  }


  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkedData = prefs.getStringList('bookmarks') ?? [];
    setState(() {
      bookmarks = bookmarkedData
          .map((e) => jsonDecode(e) as Map<String, dynamic>)
          .toList();
    });
  }


  Future<void> _saveBookmark(Map<String, dynamic> photo) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarkedData = prefs.getStringList('bookmarks') ?? [];

 
    final existingPhotoIndex =
        bookmarkedData.indexWhere((e) => jsonDecode(e)['url'] == photo['url']);

    if (existingPhotoIndex == -1) {
 
      bookmarkedData.add(jsonEncode(photo));
    } else {
 
      bookmarkedData.removeAt(existingPhotoIndex);
    }

   
    await prefs.setStringList('bookmarks', bookmarkedData);
    _loadBookmarks(); 
  }

  void _showOwnerInfo(BuildContext context, String owner, String profileImage,
      String profileUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(profileImage),
                radius: 25,
              ),
              SizedBox(height: 10),
              Text('Owner: $owner'),
              Text('Profile: $profileUrl'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gallery"),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () {
              // Navigate to bookmark screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookmarkScreen(
                    bookmarks: bookmarks,
                    onBookmark: _saveBookmark,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>( 
        future: photoData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No photos found.'));
          } else {
            final photos = snapshot.data!;
            return GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onLongPress: () {
                    _showOwnerInfo(
                      context,
                      photos[index]['owner'],
                      photos[index]['ownerImage'],
                      photos[index]['ownerProfileUrl'],
                    );
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageView(
                          imageUrl: photos[index]['fullUrl'],
                          onBookmark: () => _saveBookmark(photos[index]),
                          isBookmarked: bookmarks.any((bookmark) =>
                              bookmark['url'] == photos[index]['url']),
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: Image.network(
                      photos[index]['url'],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}




