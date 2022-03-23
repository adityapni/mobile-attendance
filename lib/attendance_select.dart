import 'package:flutter/material.dart';
import 'package:mobile_attendance/attend_workplace.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceSelection extends StatelessWidget {
  Future<SharedPreferences> getWorkplaceList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  @override
  Widget build(BuildContext context) {

    Future<SharedPreferences> prefs = getWorkplaceList();
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: FutureBuilder(
        future: prefs,
        builder: (context,AsyncSnapshot<SharedPreferences> snapshot){
          if (snapshot.hasData){
            if(snapshot.data!.getKeys().isEmpty){
              return SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: height*0.3,),
                      Text('No workplace yet'),

                    ],
                  ),
                ),
              );
            }
            List<Widget> workplaceList = snapshot.data!.getKeys().map((e) => Tile(text: e)).toList();
            return SafeArea(
              child: Center(child:
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Select workplace to attend',
                  style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 20),),
                  SizedBox(height: 20,),
                  Expanded(
                    child: ListView(children: workplaceList
                      ,padding: EdgeInsets.all(8.0),
                    ),
                  ),
                ],
              )),
            );
            
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}

class Tile extends StatelessWidget {
  Tile({
    required this.text
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Card(
      child: Center(
        child: InkWell(
          onTap: (){
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context)=>AttendWorkplace(workplaceName: this.text,)));
          },
          child: Container(
            height: height*0.1,
            width: double.infinity,
            color: Colors.grey,
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text(this.text)),
          ),
        ),
      ),
    );
  }
}
