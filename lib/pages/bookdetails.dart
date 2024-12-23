import 'package:flutter/material.dart';
import 'package:minutes_summary/pages/booksummary.dart';

class BookDetailsPage extends StatelessWidget {
  final Map<String, dynamic> book;
  BookDetailsPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Navigate to the Summary Page and replace the current screen
    void _goToSummaryPage() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryPage(
            bookname: book['name'],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'Book Details',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'fantasy',
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover image
              book['thumbnail'] != null &&
                      book['thumbnail'] != 'https://via.placeholder.com/150'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150, // Set your desired width
                          height: 250, // Set your desired height
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey,
                                width: 2), // Optional border
                          ),
                          child: Image.network(
                            book['thumbnail'],
                            fit: BoxFit
                                .cover, // Ensures the image covers the container
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                  child: Icon(Icons.error, color: Colors.red));
                            },
                          ),
                        ),
                      ],
                    )
                  : Container(),
              SizedBox(height: 16),
              // Book title, author, and genre
              Text(
                book['name'] ?? 'Unknown Title',
                style: TextStyle(
                  fontSize: screenHeight * 0.03,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.black54),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Author: ${book['author'] ?? 'Unknown Author'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Row(
                    children: [
                      Icon(Icons.bookmark, size: 16, color: Colors.black54),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Genre: ${book['genre'] ?? 'Unknown Genre'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                " Description :",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontFamily: 'fantasy',
                  fontSize: 16,
                  color: Colors.blueGrey,
                ),
                textAlign: TextAlign.justify,
              ),
              Text(
                book['description'] ?? 'No description available.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 16),

              // Get the Summary Button
              Center(
                child: ElevatedButton(
                  onPressed:
                      _goToSummaryPage, // Navigate to the summary page and replace the current screen
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Button color
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
