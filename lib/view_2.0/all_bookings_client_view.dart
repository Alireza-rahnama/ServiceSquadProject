import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_squad/controller/booking_controller.dart';

import '../model/service_booking_data.dart';

class AllBookingsClientView extends StatefulWidget {
  AllBookingsClientView({super.key});
  bool isDark = false;
  String categoryToPopulate = '';

  AllBookingsClientView.WithPersistedTheme(
      bool inheritedIsDark, String categoryName) {
    isDark = inheritedIsDark;
    categoryToPopulate = categoryName;
  }


  @override
  State<AllBookingsClientView> createState() => _AllBookingsClientViewState
      .withPersistedThemeAndCategory(
      isDark
  );
}

class _AllBookingsClientViewState extends State<AllBookingsClientView> {

  bool isDark;
  Stream<List<ServiceBookingData?>>? stream;

  _AllBookingsClientViewState.withPersistedThemeAndCategory(
      this.isDark);

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  Future<void> asyncInit() async {
    final newStream = await BookingController().getAllBookingsClient();
    setState(() {
      stream = newStream;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
        Colors.deepPurple, // Example color, ensure it's not conflicting
      ),
    );

    return Theme(
      data: themeData,
      child: Scaffold(
        // App bar with a title and a logout button.
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          title: Center(
              child: Text("Bookings",
                  style: GoogleFonts.lilitaOne(
                    color: Colors.white,
                    fontSize: 48.0,
                  ))),
          backgroundColor: Colors.deepPurple,
        ),

        // Body of the widget using a StreamBuilder to listen for changes
        // in the professionalServiceCollection  and reflect them in the UI in real-time.
        body: StreamBuilder(
          stream: stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator(),);

            List<ServiceBookingData?> bookings = snapshot.data!;
            bookings.sort((a, b) {
              if (a == null || b == null) { return 0; }
              return a.bookingStart.millisecondsSinceEpoch - b.bookingStart.millisecondsSinceEpoch;
            });
            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                ServiceBookingData? booking = bookings[index];
                if (booking == null) { return null; }

                return Column(
                    children: [
                      Card(
                          margin: EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${getDateString(booking.bookingStart)}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Spacer(),
                                  ],
                                ),
                                SizedBox(height: 15),
                                Text(
                                  'Booking length: ${booking.bookingLength / 2} hours',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 15),
                                Text(
                                  'Address: ${booking.address}',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 15),
                              ],
                            ),
                          )
                      ),
                    ]
                );
              },
            );
          },
        ),
      ),
    );
  }

  static const List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  String getDateString(DateTime dateTime) {
    String strMonth = months[dateTime.month - 1];
    String strMinute = (dateTime.minute < 10) ? "${dateTime.minute}0" : dateTime.minute.toString();
    return "$strMonth ${dateTime.day}, ${dateTime.year} ${dateTime.hour}:$strMinute";
  }
}
