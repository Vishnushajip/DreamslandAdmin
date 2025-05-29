import 'package:dladmin/Admin/DashBoard/Verfied_Tabs/Verfied_req.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PropertyRequestTabs extends StatelessWidget {
  const PropertyRequestTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                splashFactory: NoSplash.splashFactory,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                dividerColor: Colors.white,
                indicatorAnimation: TabIndicatorAnimation.linear,
                tabs: [
                  Tab(
                    icon: FaIcon(
                      FontAwesomeIcons.solidHourglassHalf,
                      color: Colors.black,
                    ),
                    child: Text(
                      'Pending',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Tab(
                    icon: Icon(Icons.verified, color: Colors.black),
                    child: Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Tab(
                    icon: FaIcon(
                      FontAwesomeIcons.trashAlt,
                      color: Colors.black,
                    ),
                    child: Text(
                      'Rejected',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  VerifiedDocumentsScreen(status: "Pending"),
                  VerifiedDocumentsScreen(status: "Verified by Admin"),
                  VerifiedDocumentsScreen(status: "Rejected by Admin"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
