import 'package:flutter/material.dart';
import 'package:modern_form_line_awesome_icons/modern_form_line_awesome_icons.dart';

class HostelRoomDetail extends StatelessWidget {
  final Map<String, dynamic> adData;

  HostelRoomDetail({required this.adData});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;


    // Calculate text and container sizes based on screen width
    final titleFontSize = screenWidth < 600 ? 24.0 : 28.0;
    final descriptionFontSize = screenWidth < 600 ? 14.0 : 16.0;
    final containerHeight = screenWidth < 600 ? 100.0 : 130.0;

    return Expanded(
      child: ListView(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: 30,
              left: 30,
              right: 30,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price: ${adData['price']}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Address: ${adData['address']}',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black.withOpacity(0.4),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  'City: ${adData['city']}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.only(left: 30, bottom: 30),
            child: Text(
              'Hostel Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 30,
                    bottom: 30,
                  ),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Gender',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        if (adData['gender'] == 'Boys Hostel')
                          Icon(
                            Icons.boy, // Display a boy icon if gender is 'Boy'
                            size: 50,
                            color: Colors.blue, // You can adjust the color
                          )
                        else if (adData['gender'] == 'Girls Hostel')
                          Icon(
                            Icons.girl, // Display a girl icon if gender is 'Girl'
                            size: 30,
                            color: Colors.pink, // You can adjust the color
                          )
                        else
                          Text(
                            'Unknown Gender', // Display this text if gender is neither 'Boy' nor 'Girl'
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  )
                ),
                Padding(
                    padding: EdgeInsets.only(
                      left: 30,
                      bottom: 30,
                    ),
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'AC',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          if (adData['AC'] == 'Yes')
                            Icon(
                              Icons.ac_unit_sharp,
                              size: 50,
                              color: Colors.blue, // You can adjust the color
                            )
                          else if (adData['AC'] == 'No')
                            Icon(
                              Icons.cancel_sharp,
                              size: 30,
                              color: Colors.pink, // You can adjust the color
                            )
                          else
                            Text(
                              'Ac Available on demand',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    )
                ),
                Padding(
                    padding: EdgeInsets.only(
                      left: 30,
                      bottom: 30,
                    ),
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'UPS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          if (adData['UPS'] == 'Yes')
                            Icon(
                              Icons.battery_std_sharp,
                              size: 50,
                              color: Colors.blue, // You can adjust the color
                            )
                          else if (adData['UPS'] == 'No')
                            Icon(
                              Icons.battery_alert_sharp,
                              size: 30,
                              color: Colors.pink, // You can adjust the color
                            )
                          else
                            Text(
                              'No Ups Available',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    )
                ),
                Padding(
                    padding: EdgeInsets.only(
                      left: 30,
                      bottom: 30,
                    ),
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Internet',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          if (adData['Internet'] == 'Yes')
                            Icon(
                              Icons.wifi_2_bar_sharp,
                              size: 50,
                              color: Colors.blue, // You can adjust the color
                            )
                          else if (adData['Internet'] == 'No')
                            Icon(
                              Icons.portable_wifi_off_sharp,
                              size: 30,
                              color: Colors.pink, // You can adjust the color
                            )
                          else
                            Text(
                              'No Internet Available',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    )
                ),
                Padding(
                    padding: EdgeInsets.only(
                      left: 30,
                      bottom: 30,
                    ),
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Rooms',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          if (adData['Rooms'] == 'Single')
                            Icon(
                              Icons.single_bed,
                              size: 50,
                              color: Colors.blue, // You can adjust the color
                            )
                          else if (adData['Rooms'] == 'Double')
                            Icon(
                              Icons.person_2_rounded,
                              size: 30,
                              color: Colors.pink, // You can adjust the color
                            )
                          else if (adData['Rooms'] == 'Triple')
                              Icon(
                                Icons.three_mp,
                                size: 30,
                                color: Colors.pink, // You can adjust the color
                              )
                            else if (adData['Rooms'] == 'Quad')
                                Icon(
                                  Icons.four_mp,
                                  size: 30,
                                  color: Colors.pink, // You can adjust the color
                                )
                          else
                            Text(
                              'No Room Available',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    )
                ),
                Padding(
                    padding: EdgeInsets.only(
                      left: 30,
                      bottom: 30,
                    ),
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Parking',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          if (adData['Parking'] == 'Yes')
                            Icon(
                              Icons.local_parking_sharp,
                              size: 50,
                              color: Colors.blue, // You can adjust the color
                            )
                          else if (adData['Parking'] == 'No')
                            Icon(
                              Icons.cancel_sharp,
                              size: 30,
                              color: Colors.pink, // You can adjust the color
                            )
                          else
                            Text(
                              'No Parking Available',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    )
                ),


              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 30,
              right: 30,
              bottom: 30 * 4,
            ),
            child: Text(
              '${adData['description']}',
              style: TextStyle(
                color: Colors.black.withOpacity(0.4),
                height: 1.5,
              ),
            ),
          )
        ],
      ),
    );



  }
}

