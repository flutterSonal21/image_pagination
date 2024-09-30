

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:unsplish_api_img/model/PhotosModel.dart';
import 'package:unsplish_api_img/services/dioservices.dart';

class AppController extends GetxController {
  RxList<PhotosModel> photos = <PhotosModel>[].obs;
  RxBool isLoading = true.obs;
  RxBool isLoadingNewImages = false.obs;
  int currentPage = 1;
  final int itemsPerPage = 10;
  RxString searchQuery = ''.obs;
  RxList<String> searchHistory = <String>[].obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchSearchHistory();
  }

  Future<void> getPictureData() async {
    isLoading.value = true;

    final response = await DioService.getURL(
      "https://api.unsplash.com/photos/?client_id=8xfdimStxBRSlql5WLZ0bCJPUTAiPSZ810Mw_L-qDy4&page=$currentPage&per_page=$itemsPerPage"
    );

    if (response.statusCode == 200) {
      photos.addAll((response.data as List)
          .map((element) => PhotosModel.fromJson(element))
          .toList());
    } else {
      Get.snackbar('Error', 'Failed to load images');
    }
    isLoading.value = false;
  }

  Future<void> searchImages(String query) async {
    isLoading.value = true;
    currentPage = 1;
    photos.clear();
    searchQuery.value = query;

    final response = await DioService.getURL(
      "https://api.unsplash.com/search/photos?client_id=8xfdimStxBRSlql5WLZ0bCJPUTAiPSZ810Mw_L-qDy4&query=$query&page=$currentPage&per_page=$itemsPerPage"
    );

    if (response.statusCode == 200) {
      photos.addAll((response.data['results'] as List)
          .map((element) => PhotosModel.fromJson(element))
          .toList());
      await saveSearchHistory(query);
    } else {
      Get.snackbar('Error', 'Failed to load search results');
    }
    isLoading.value = false; // Make sure to set loading to false here
  }

  Future<void> loadMoreImages() async {
    currentPage++;
    isLoadingNewImages.value = true;
    await getPictureData();
    isLoadingNewImages.value = false;
  }

  // Other methods remain unchanged...

  Future<void> fetchSearchHistory() async {
  try {
    // Fetching the document from the 'searchkey' collection
    var snapshot = await _firestore.collection('searchkey').get();

    // Extract the 'keywords' array from the document
    if (snapshot.docs.isNotEmpty) {
      searchHistory.value = snapshot.docs
          .expand((doc) {
            // Check if 'keywords' exists and is not null
            if (doc.data().containsKey('keywords') && doc['keywords'] != null) {
              return List<String>.from(doc['keywords']); // Convert to a List<String>
            } else {
              return ['Unknown Query']; // Default value if missing or null
            }
          })
          .toList();
    }

    // print("Fetched search history: ${searchHistory.value}");

    if (searchHistory.isEmpty) {
      Get.snackbar('Info', 'No search history found');
    }
  } catch (e) {
    Get.snackbar('Error', 'Failed to load search history: $e');
  }
}
Future<void> saveSearchHistory(String keyword) async {
      
        try {
          // Save the keyword in Firestore
          await _firestore.collection('searchkey').doc().set(
            {
              'keywords': FieldValue.arrayUnion([keyword])
              
            },
            SetOptions(merge: true), // Merge to avoid overwriting existing data
            
          );
          print("$keyword--------------------in database");
        } catch (e) {
          print("Error storing keyword: $e-----------");
        }

      
  }

  void addToSearchHistory(String query) {
    if (!searchHistory.contains(query)) {
      searchHistory.add(query);
    }
  }
}
