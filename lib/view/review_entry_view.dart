import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:image_picker/image_picker.dart';
import 'package:service_squad/view/reviews_list_view.dart';
import 'dart:io';

import '../controller/professional_service_controller.dart';
import '../controller/profile_controller.dart';
import '../model/professional_service.dart';
import 'services_list_view.dart';

class ReviewEntryView extends StatefulWidget {
  bool isDark;
  ProfessionalService professionalService;

  ReviewEntryView.withInheritedTheme(this.isDark, this.professionalService);

  @override
  // _NewEntryViewState createState() => _NewEntryViewState();
  _NewEntryViewState createState() =>
      _NewEntryViewState.withInheritedThemeAndCategory(
          isDark, professionalService);
}

class _NewEntryViewState extends State<ReviewEntryView> {
  final TextEditingController reviewController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();

  String? review;
  int? rating;
  final service;

  _NewEntryViewState.withInheritedThemeAndCategory(
      bool isDark, ProfessionalService professionalService)
      : service = professionalService;

  void _saveReviewEntry() async {
    ProfessionalService professionalService = service;
    final professionalServiceController = ProfessionalServiceController();
    review = reviewController.text;
    // rating = int.tryParse(ratingController.text)?? 5;

    if (review == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Center(
                child: Text('Review can not b empty!',
                    style: TextStyle(
                      color: Colors.white, // Customize the hint text color
                      fontSize: 12, // Customize the hint text font size
                    ))),
            backgroundColor: Colors.deepPurple),
      );
      return;
    }
    List<String?> newReviewList = professionalService.reviewList ?? [];
    newReviewList.add(review);

    ProfessionalService newProfessionalService = ProfessionalService(
        id: professionalService.id,
        category: professionalService.category,
        serviceDescription: professionalService.serviceDescription,
        wage: professionalService.wage,
        rating: rating,
        location: professionalService.location,
        technicianAlias: professionalService.technicianAlias!,
        imagePath: professionalService.imagePath,
        reviewList: newReviewList);

    professionalServiceController
        .updateProfessionalService(newProfessionalService);

    reviewController.clear();
    ratingController.clear();

    print('rating is: $rating');
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Center(
                child: Text('Review successfully saved!',
                    style: TextStyle(
                      color: Colors.white, // Customize the hint text color
                      fontSize: 12, // Customize the hint text font size
                    ))),
            backgroundColor: Colors.deepPurple),
      );
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ReviewsView.forEachProfessionalService(false, service)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Unexpected error ocured: $e'),
            backgroundColor: Colors.deepPurple),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData =
        ThemeData(useMaterial3: true, brightness: Brightness.light);

    return Theme(
        data: themeData,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.deepPurple,
              title: Text("Add a review",
                  style: GoogleFonts.pacifico(
                    color: Colors.white,
                    fontSize: 30.0,
                  )),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back_outlined),
                  tooltip: 'Go back',
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ),
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,

                  children: <Widget>[
                    SizedBox(height: 150.0),

                    TextField(
                      controller: reviewController,
                      decoration: InputDecoration(
                        labelText: 'write a review',
                        hintText:
                            'write a review', //TODO: BETTER MAKE IT A DROP DOWN OR RADIO BUTTON
                      ),
                      maxLength: 50, // Set the maximum character limit
                      maxLines: null, // Allow multiple lines of text
                    ),
                    // TextField(
                    //   controller: ratingController,
                    //   decoration: InputDecoration(
                    //       labelText: 'Rate your experience',
                    //       hintText:
                    //           'Rate your experience from 1 to 5,' //TODO: BETTER MAKE IT A DROP DOWN OR RADIO BUTTON
                    //       ),
                    //   maxLength: 50, // Set the maximum character limit
                    //   maxLines: null, // Allow multiple lines of text
                    // ),
                    SizedBox(height: 50,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Rate your experience:'),
                        Spacer(),
                        RatingBar.builder(
                          initialRating: 3,
                          itemCount: 5,
                          itemBuilder: (context, index){
                            switch (index) {
                              case 0:
                                return Icon(
                                  Icons.sentiment_very_dissatisfied,
                                  color: Colors.red,
                                );
                              case 1:
                                return Icon(
                                  Icons.sentiment_dissatisfied,
                                  color: Colors.redAccent,
                                );
                              case 2:
                                return Icon(
                                  Icons.sentiment_neutral,
                                  color: Colors.amber,
                                );
                              case 3:
                                return Icon(
                                  Icons.sentiment_satisfied,
                                  color: Colors.lightGreen,
                                );
                              case 4:
                                return Icon(
                                  Icons.sentiment_very_satisfied,
                                  color: Colors.green,
                                );
                              default:
                                return Container(height: 0.0);
                            }
                          },
                          onRatingUpdate: (ratingValue) {
                            print(ratingValue);
                            rating = ratingValue.toInt();
                          },
                        ),
                      ],
                    ),
                    // RatingBar.builder(
                    //     initialRating: 3,
                    //     itemCount: 5,
                    //     itemBuilder: (context, index){
                    //       switch (index) {
                    //         case 0:
                    //           return Icon(
                    //             Icons.sentiment_very_dissatisfied,
                    //             color: Colors.red,
                    //           );
                    //         case 1:
                    //           return Icon(
                    //             Icons.sentiment_dissatisfied,
                    //             color: Colors.redAccent,
                    //           );
                    //         case 2:
                    //           return Icon(
                    //             Icons.sentiment_neutral,
                    //             color: Colors.amber,
                    //           );
                    //         case 3:
                    //           return Icon(
                    //             Icons.sentiment_satisfied,
                    //             color: Colors.lightGreen,
                    //           );
                    //         case 4:
                    //           return Icon(
                    //             Icons.sentiment_very_satisfied,
                    //             color: Colors.green,
                    //           );
                    //         default:
                    //           return Container(height: 0.0);
                    //       }
                    //     },
                    //     onRatingUpdate: (ratingValue) {
                    //       print(ratingValue);
                    //       rating = ratingValue.toInt();
                    //     },
                    // ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: <Widget>[
                    //     Text('Rate Your Day:'),
                    //     Slider(
                    //       value: rating?.toDouble() ?? 5.0,
                    //       // Use rating as the initial value
                    //       min: 1,
                    //       max: 5,
                    //       onChanged: (newRating) {
                    //         setState(() {
                    //           rating = newRating.round();
                    //         });
                    //       },
                    //     ),
                    //   ],
                    // ),
                    SizedBox(height: 50),
                    // Container(height: 50.0,),
                    ElevatedButton(
                      onPressed: _saveReviewEntry,
                      child: Text('Save Entry'),
                    ),
                  ],
                ))));
  }
}

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Error Exception'),
      content: const Text(
          'You are already providing this service, instead of creating new posting modify your existing ad!'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
