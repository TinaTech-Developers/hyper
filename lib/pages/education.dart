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
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.asset(
                                  material.coverImage,
                                  width: 100, // Set a fixed width for the image
                                  height:
                                      60, // Set a fixed height for the image
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(material.title),
                              subtitle:
                                  Text('Description: ${material.description}'),
                              onTap: () {
                                // Open the material details page
                                final materialUrl = material.url;
                                final imageUrl = material.coverImage;
                                final title = material.title;
                                final desc = material.description;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookDetailPage(
                                      bookUrl: materialUrl,
                                      image: imageUrl,
                                      title: title,
                                      description: desc,
                                    ),
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
  final String image;
  final String title;
  final String description;

  const BookDetailPage(
      {required this.bookUrl,
      required this.image,
      required this.title,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Material Details'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                image,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            SelectableText(
              description,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            SizedBox(height: 30),
            // ElevatedButton.icon(
            //   onPressed: () {
            //     _launchURL(bookUrl);
            //   },
            //   icon: Icon(Icons.open_in_new),
            //   label: Text('View Material Details'),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.deepPurple,
            //     padding: EdgeInsets.symmetric(vertical: 15),
            //     textStyle: TextStyle(fontSize: 16),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

//   void _launchURL(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }
}
