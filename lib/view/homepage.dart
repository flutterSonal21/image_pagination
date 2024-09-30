

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unsplish_api_img/controller/homecontroller.dart';
import 'package:unsplish_api_img/view/detail_view.dart';
import 'package:unsplish_api_img/view/login_page.dart';


class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppController homeController = Get.put(AppController());
  final TextEditingController searchController = TextEditingController();
  String? selectedSearchHistory; // To track the selected search history item

  @override
  void initState() {
    super.initState();
    homeController.getPictureData();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text("IMAGE SEARCH APP"),
      backgroundColor: Color.fromARGB(255, 42, 181, 123),
      actions: [
        IconButton(
          icon: Icon(Icons.login), // Replace with your desired icon
          onPressed: () {
            // Navigate to the login page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()), // Replace LoginPage with your actual login page widget
            );
          },
        ),
      ],
    ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                // color: Colors.blueAccent,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/1.jpeg'), // Replace with your image path
                      fit: BoxFit.cover, // Adjusts how the image fits the container
                    ),
                  ),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    _buildtext(),
                    const SizedBox(height: 25),
                    _buildSearchBar(),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              _buildImageCarousel(),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildtext(){
    return  Center(
                      child: Text("What would you like to find?",style: TextStyle(fontSize: 25,color: Colors.white),),
    );
  }
  Widget _buildSearchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Search images...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              // borderSide: BorderSide.none,
              borderSide: BorderSide(color: Colors.white, width: 1),
            ),
            filled: true,
            fillColor:  Colors.white,
            prefixIcon: Icon(Icons.search),
          ),
          style: TextStyle(color: Color.fromARGB(255, 108, 31, 72)),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _performSearch(value);
            }
          },
        ),
        const SizedBox(height: 10),
        Obx(() {
          return DropdownButtonFormField<String>(
            value: selectedSearchHistory,
            hint: Text("Select from history",style: TextStyle(
              color: Colors.black,
              fontSize: 13,
            ),),
            onChanged: (String? newValue) {
              if (newValue != null) {
                _performSearch(newValue);
                setState(() {
                  selectedSearchHistory = newValue; // Update selected value
                  searchController.text = newValue; // Update text field
                });
              }
            },
            items: homeController.searchHistory.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white, // Change this to your desired color
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none, // Remove border
            ),
          ),
          );
        }),
      ],
    );
  }

  void _performSearch(String query) {
    homeController.searchImages(query);
    homeController.addToSearchHistory(query); // Add to history
    searchController.clear();
    setState(() {
      selectedSearchHistory = query; // Update selected value
    });
  }

Widget _buildImageCarousel() {
  Timer? _timer;
  PageController pageController = PageController(initialPage: 0);
  var currentPage = 0.obs; // Observing the current image index

  // Limit to 30 images in total
  const totalImages = 30;
  const imagesPerPage = 10; // Number of images per page
  const totalPages = totalImages ~/ imagesPerPage; // Calculate total pages

  return Obx(() {
    if (homeController.isLoading.value && homeController.photos.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    // Limit the photos to only 30 items
    List limitedPhotos = homeController.photos.take(totalImages).toList();

    // Function to start auto-sliding images
    void startTimer() {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (pageController.page == totalImages - 1) {
          pageController.animateToPage(
            0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          pageController.nextPage(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }

    // Start the timer on the first build
    if (_timer == null) {
      startTimer();
    }

    return Stack(
      children: [
        SizedBox(
          height: 450,
          child: PageView.builder(
            itemCount: limitedPhotos.length,
            controller: pageController,
            onPageChanged: (index) {
              currentPage.value = index; // Update current page index
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsView(index: index),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: CachedNetworkImage(
                    imageUrl: limitedPhotos[index].urls!['small']!,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),

        // Circle page indicators
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Obx(() {
              int currentPageIndex = (currentPage.value ~/ imagesPerPage); // Determine which page we're on
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(totalPages-1, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: CircleAvatar(
                      radius: 6,
                      backgroundColor: currentPageIndex == index
                          ? Colors.pink // Pink for the active page
                          : Colors.white, // White for inactive pages
                    ),
                  );
                }),
              );
            }),
          ),
        ),
      ],
    );
  });
}}