import 'package:agent_second/constants/colors.dart';
import 'package:agent_second/constants/config.dart';
import 'package:agent_second/constants/styles.dart';
import 'package:agent_second/localization/trans.dart';
import 'package:agent_second/util/data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:agent_second/util/dio.dart';
import 'package:flutter_svg/svg.dart';
import 'package:location/location.dart';

class GlobalDrawer extends StatefulWidget {
  const GlobalDrawer({
    Key key,
    @required this.sourceContext,
  }) : super(key: key);
  final BuildContext sourceContext;

  @override
  _GlobalDrawerState createState() => _GlobalDrawerState();
}

class _GlobalDrawerState extends State<GlobalDrawer> {
  String agentName;

  void restoreData() {
    data.getData("agent_name").then((String value) {
      setState(() {
        agentName = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // location.onLocationChanged.listen((LocationData currentLocation) {
    //   latTosend = currentLocation.latitude;
    //   longTosend = currentLocation.longitude;
    //   print(
    //       "hola hola lat ${currentLocation.latitude} hola hola long ${currentLocation.longitude}");
    // });
    restoreData();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(agentName, style: styles.underHeadwhite),
                  ],
                ),
                // CachedNetworkImage(imageUrl: config.logo),
                // SvgPicture.asset('assets/images/company_logo.svg',
                //     width: 80.0, height: 80.0),
                ClipRRect(
                    borderRadius: BorderRadius.circular(100.0),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: colors.trans,
                      child: CachedNetworkImage(imageUrl: config.logo),
                    ))
              ],
            ),
            decoration: const BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                  widget.sourceContext, "/Home", (_) => false);
            },
            title: Text(trans(context, "home"), style: styles.globalDrawer),
          ),
          ListTile(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(widget.sourceContext,
                  "/Beneficiaries", (Route<dynamic> r) => r.isFirst);
            },
            title: Text(trans(context, "beneficiaries"),
                style: styles.globalDrawer),
          ),
          const Divider(),
          ListTile(
            onTap: () {
              final double x = MediaQuery.of(context).size.width;
              Navigator.pushNamedAndRemoveUntil(widget.sourceContext,
                  "/Agent_Orders", (Route<dynamic> r) => r.isFirst,
                  arguments: <String, dynamic>{"expand": true, "width": x});
            },
            title: Text(trans(context, "stock_transaction"),
                style: styles.globalDrawer),
          ),
          ListTile(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(widget.sourceContext, "/items",
                  (Route<dynamic> r) => r.isFirst);
            },
            title: Text(trans(context, "items"), style: styles.globalDrawer),
          ),
        ],
      ),
    );
  }
}
