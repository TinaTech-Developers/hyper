import 'dart:convert';
import 'package:flutter/services.dart';
import 'educational_material.dart';

class LoadMaterials {
  // Function to load the JSON file from assets
  Future<List<EducationalMaterial>> loadEducationalMaterials() async {
    // Ensure the file path is correct
    final String response =
        await rootBundle.loadString('assets/educational_material.json');

    // Decode the JSON data
    final data = json.decode(response);

    // Check if 'education_materials' exists and has data
    if (data['education_materials'] == null) {
      throw Exception('No education materials found');
    }

    // Parse the 'education_materials' array from the JSON
    List<EducationalMaterial> materials = (data['education_materials'] as List)
        .map((item) => EducationalMaterial.fromJson(item))
        .toList();

    return materials;
  }
}
