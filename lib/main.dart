import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:proyek_akhir_miot_c/api/sheets/proyekakhir_m_iot_c.dart';
import 'package:proyek_akhir_miot_c/models/dataSensor.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SheetsAPI.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Proyek Akhir",
      theme: ThemeData(
        primarySwatch: Colors.brown,
        fontFamily: 'Inter'
      ),
      home: const HalamanUtama(title: "Mobile IoT C : K2"),
    );
  }
}
  

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key, required this.title});
  
  final String title;
  
  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {

  List<dataSensor> datas = [];
  Query ref = FirebaseDatabase.instance.ref().child('data');
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    getDatas();
  }

  Future getDatas() async {
    final datas = await SheetsAPI.getAll();

    setState(() {
      this.datas = datas;
    });

  }

  Widget dataList( List<dataSensor> dataList) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: dataList.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Kelembaban  : "+ dataList[index].kelembaban.toString() +" %"),
                Text("Suhu              : "+ dataList[index].suhu.toString() +" ℃"),
                Text("Update Time : "+ dataList[index].updated_at.toString()),
              ],
            ),
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(widget.title),
        )
      ),
      body: RefreshIndicator(key: _refreshIndicatorKey,onRefresh: getDatas,
      child: Padding(
              padding: EdgeInsets.all(20), 
              child:FirebaseAnimatedList(
                  query: ref,
                  itemBuilder:(context, snapshot, animation, index) {
                    Map data = snapshot.value as Map;
                    return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 150,
                                width: 350,
                                margin: EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  borderRadius: BorderRadius.all(Radius.circular(30)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Kelembaban",
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold
                                    ),
                                    ),
                                    Text(data['kelembaban'].toString()+" %",
                                    style: TextStyle(
                                      fontSize: 25,
                                    ),),
                                  ],
                                ),
                              ),
                              Container(
                                height: 150,
                                width: 350,
                                margin: EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  color: Colors.amberAccent,
                                  borderRadius: BorderRadius.all(Radius.circular(30)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Suhu", 
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold
                                    ),
                                    ),
                                    Text(data['suhu'].toString()+" ℃",
                                    style: TextStyle(
                                      fontSize: 25,
                                    ),)
                                  ],
                                ),
                              ),
                              dataList(datas),
                            ],
                          );
                  },
                ),
              ),
      )
    );
  }
}