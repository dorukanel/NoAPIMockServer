class MockDataService {
  Map<String, dynamic> _mockDatabase = {
    'users': {
      '7X4yCJLHJaYeBI82zmNd': {
        'uid': '7X4yCJLHJaYeBI82zmNd',
        'name': 'John Doe',
        'email': 'john.doe@example.com',
      },
      '8Y5zDKIHJaYeBI83znOe': {
        'uid': '8Y5zDKIHJaYeBI83znOe',
        'name': 'Jane Smith',
        'email': 'jane.smith@example.com',
      },
    },
    // Add other collections and documents as needed
  };

  Future<Map<String, dynamic>?> getDocument(String collection, String docId) async {
    var collectionData = _mockDatabase[collection];
    if (collectionData != null) {
      return collectionData[docId];
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getCollection(String collection) async {
    var collectionData = _mockDatabase[collection];
    if (collectionData != null) {
      return collectionData.values.toList();
    }
    return [];
  }
}
