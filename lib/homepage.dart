import 'dart:convert';
import 'package:covidindia/components/most_effected_pannel.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:covidindia/components/worldwide_pannel.dart';
import 'package:http/http.dart' as http;
import 'package:covidindia/pages/countrystats.dart';
import 'package:pie_chart/pie_chart.dart';

const String apiurl = 'https://corona.lmao.ninja/v2';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Map worldData;
  Future<dynamic> getWorldwideData() async {
    try {
      http.Response response = await http.get('$apiurl/all');
      setState(() {
        worldData = jsonDecode(response.body);
      });
    } catch (e) {
      print('cant fetch data');
    }
  }

  List countrydata;
  Future<dynamic> getmostAffectedcountries() async {
    try {
      http.Response response =
          await http.get('$apiurl/countries?yesterday=false&sort=deaths');
      setState(() {
        countrydata = jsonDecode(response.body);
      });
    } catch (e) {
      print('cant fetch data');
    }
  }

//comibe above two functions
  Future<dynamic> combineFuncationAlldata() async {
    getWorldwideData();
    getmostAffectedcountries();
  }

  @override
  void initState() {
    super.initState();
    combineFuncationAlldata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.light
                  ? Icons.lightbulb_outline
                  : Icons.highlight,
              color: Colors.white,
            ),
            onPressed: () {
              DynamicTheme.of(context).setBrightness(
                  Theme.of(context).brightness == Brightness.light
                      ? Brightness.dark
                      : Brightness.light);
            },
          )
        ],
        title: Text(
          'Covid-19 Status',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: combineFuncationAlldata,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Covid-19 WorldWide ',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              worldData == null
                  ? CircularProgressIndicator()
                  : WorldwidePannel(
                      data: worldData,
                    ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.all(25),
                child: worldData == null
                    ? Container()
                    : PieChart(dataMap: {
                        'Confirmed': worldData['cases'].toDouble(),
                        'Active': worldData['active'].toDouble(),
                        'Recovered': worldData['recovered'].toDouble(),
                        'Death': worldData['deaths'].toDouble(),
                      }, colorList: [
                        Color(0xffff7675),
                        Color(0xff74b9ff),
                        Color(0xff55efc4),
                        Color(0xffb7b7b7),
                      ]),
              ),
              SizedBox(height: 15),
              Material(
                elevation: 10,
                color: Colors.red.shade600,
                //Color(0xff263238),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: MaterialButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CountryPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Countries Details',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
              Text('Most Effected Countries ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 15),
              countrydata == null
                  ? Container()
                  : MosteffectedPannel(
                      countrydata: countrydata,
                    ),
              SizedBox(height: 25),
              Container(
                //last updated
                height: 45,
                width: 140,
                decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    'Updated On ${DateTime.now()},',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Made by Neeraj',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
