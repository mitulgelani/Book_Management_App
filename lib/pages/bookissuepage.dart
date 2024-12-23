import 'package:flutter/material.dart';
import 'package:minutes_summary/pages/bookdetails.dart';

class BookIssueHomePage extends StatefulWidget {
  const BookIssueHomePage({super.key});

  @override
  _BookIssueHomePageState createState() => _BookIssueHomePageState();
}

class _BookIssueHomePageState extends State<BookIssueHomePage> {
  List<String> books = [
    'The Alchemist',
    '1984',
    'To Kill a Mockingbird',
    'The Great Gatsby',
    'Moby Dick',
  ];
  List<String> filteredBooks = [];

  @override
  void initState() {
    super.initState();
    // Initially display all books
    filteredBooks = books;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Issue System'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar using TextField
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search Books',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  // Filter books based on search input
                  filteredBooks = books
                      .where((book) =>
                          book.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredBooks.isEmpty
                  ? const Center(child: Text('No books found.'))
                  : ListView.builder(
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        final book = filteredBooks[index];
                        return ListTile(
                          title: Text(book),
                          onTap: () {
                            // Navigate to BookDetailsPage with selected book
                            /*  Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookDetailsPage(bookName: book),
                              ),
                            ); */
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
