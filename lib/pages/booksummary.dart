import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class SummaryPage extends StatefulWidget {
  String bookname;
  SummaryPage({
    Key? key,
    required this.bookname,
  }) : super(key: key);

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _summaryList = []; // List to hold each chunk of summary
  bool _isLoading = false;

  late PageController _pageController;
  int _currentPage = 0; // To track the current page index

  // Initialize the Gemini model with your API key
  late final GenerativeModel _gemini;

  @override
  void initState() {
    super.initState();
    _gemini = GenerativeModel(
      model: 'gemini-pro', // Ensure the correct model is specified
      apiKey:
          'AIzaSyDgXM4zQTg2fyXSZRuZTdu8URwwOevH-Gg', // Replace with your actual API key
    );
    _pageController = PageController();

    _generateSummary();
  }

  Future<void> _generateSummary() async {
    setState(() {
      _isLoading = true;
      _summaryList = [];
    });

    try {
      final response = await _gemini.generateContent(
        [
          Content.text(
              'Summarize the book titled "${widget.bookname}". give paragraph summary in 8-9 paragraphs. there must not be any new lines "\\n"')
        ],
      );

      setState(() {
        String summaryText = response.text ?? 'No summary available.';
        print(summaryText);

        // Split the summary into chunks (based on paragraphs or sentences)
        _summaryList = summaryText
            .split('\n') // Split the summary into lines
            .where((line) => line.trim().isNotEmpty) // Filter out empty lines
            .toList(); // Convert it back to a list
      });
    } catch (e) {
      setState(() {
        _summaryList = ['Error generating summary: $e'];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController
        .dispose(); // Dispose of the PageController when the widget is disposed
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Book Summary',
          style: TextStyle(color: Colors.white60),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white60, // Set the color of the back arrow
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.white, width: 1), // White thin border
                borderRadius: BorderRadius.circular(12), // Curvy border radius
              ),
              padding:
                  EdgeInsets.all(8), // Optional padding inside the container
              child: Text(
                widget.bookname,
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontFamily: "fantasy", // Font style
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.35),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.grey),
                    ),
                  )
                : Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _summaryList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  _summaryList[index],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      onPageChanged: _onPageChanged, // Listen for page changes
                    ),
                  ),
            const SizedBox(height: 20),
            _isLoading
                ? Container()
                : Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _summaryList.length,
                        (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 2),
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? Colors.white
                                : Colors
                                    .grey, // Update dot color based on current page
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
