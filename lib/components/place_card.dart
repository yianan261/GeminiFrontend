import 'package:flutter/material.dart';
import '/services/places_service.dart';
import '/components/icon_button.dart';
import '/pages/place_detail_page.dart';

class PlaceCard extends StatefulWidget {
  final Map<String, dynamic> place;
  final ValueChanged<bool>? onBookmarkToggle;

  const PlaceCard({
    Key? key,
    required this.place,
    this.onBookmarkToggle,
  }) : super(key: key);

  @override
  _PlaceCardState createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    isBookmarked = widget.place['bookmarked'] ?? false;
  }

  void _toggleBookmark() async {
    try {
      if (isBookmarked) {
        await removeBookmarkedPlace(place: widget.place);
      } else {
        await savePlace(place: widget.place);
      }
      widget.onBookmarkToggle?.call(!isBookmarked);
      setState(() {
        isBookmarked = !isBookmarked;
        widget.place['bookmarked'] = isBookmarked;
      });
    } catch (e) {
      print('Failed to toggle bookmark: $e');
    }
  }

  void _navigateToPlaceDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceDetailPage(
          placeId: widget.place['place_id'],
          onBookmarkToggle: (isBookmarked) {
            widget.onBookmarkToggle?.call(isBookmarked);
            setState(() {
              this.isBookmarked = isBookmarked;
              widget.place['bookmarked'] = isBookmarked;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToPlaceDetail,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: widget.place['photo_url'][0] != null
                      ? Image.network(
                    widget.place['photo_url'][0],
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    height: 150,
                    color: Colors.grey,
                    child: Icon(Icons.photo, size: 100, color: Colors.white),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 16,
                    child: MyIconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? Colors.yellow : Colors.white,
                      ),
                      iconSize: 15.0,
                      onPressed: _toggleBookmark,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.place['title'] ?? 'No Name',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '${widget.place['distance'].toStringAsFixed(2)} mi',
                style: TextStyle(fontSize: 12, color: Colors.blueGrey),
              ),
            ),
            SizedBox(height: 8), // Add this to ensure there's padding at the bottom
          ],
        ),
      ),
    );
  }
}
