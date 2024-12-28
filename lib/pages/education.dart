import 'package:flutter/material.dart';
import 'load_materials.dart'; // Import the helper class
import 'educational_material.dart'; // Import the model

class EducationPage extends StatefulWidget {
  @override
  _EducationPageState createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  final LoadMaterials _loadMaterials = LoadMaterials();
  List<EducationalMaterial> _materials = [];
  List<EducationalMaterial> _filteredMaterials = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _searchController.addListener(_filterMaterials);
  }

  // Load the educational materials from the JSON file
  Future<void> _loadBooks() async {
    try {
      final materials = await _loadMaterials.loadEducationalMaterials();
      setState(() {
        _materials = materials;
        _filteredMaterials = materials; // Show all initially
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading materials: $e')),
      );
    }
  }

  // Filter the list of materials based on search input
  void _filterMaterials() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMaterials = _materials.where((material) {
        return material.title.toLowerCase().contains(query) ||
            material.author.toLowerCase().contains(query) ||
            material.category.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Educational Materials'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _filteredMaterials.isEmpty
                  ? Center(child: Text('No materials found'))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _filteredMaterials.length,
                        itemBuilder: (context, index) {
                          final material = _filteredMaterials[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              leading: Image.network(material.coverImage),
                              title: Text(material.title),
                              subtitle: Text('Author: ${material.author}'),
                              onTap: () {
                                // Open the material details page
                                final materialUrl = material.url;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BookDetailPage(bookUrl: materialUrl),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}

class BookDetailPage extends StatelessWidget {
  final String bookUrl;

  const BookDetailPage({required this.bookUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Material Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Material URL:'),
            SizedBox(height: 10),
            Text(bookUrl, style: TextStyle(color: Colors.blue)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Launch the URL (optional, you can use url_launcher package here)
                _launchURL(bookUrl);
              },
              child: Text('View Material Details'),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) {
    // You can use the url_launcher package to open the URL
    // Example: launch(url);
  }
}
