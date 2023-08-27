import 'package:flutter/material.dart';
import 'package:flutter_test_application_1/core/card_decorations.dart';

class MenuCard extends StatelessWidget {
  const MenuCard({
    required this.menuItem,
    required this.imageUrl,
    required this.routeUrl, // Add the required parameter here
  });

  final String menuItem;
  final String imageUrl;
 final Widget  routeUrl;

  @override
  Widget build(BuildContext context, ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => routeUrl, // Replace YourNextPage with the actual destination page
          ),
        );
      },
      child: Container(
          decoration: CardDecorations.boxDecoration,
          child: ListTile(
            contentPadding: EdgeInsets.all(10),
            title: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 75,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: AssetImage(imageUrl),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  child: Text(
                    menuItem,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}


