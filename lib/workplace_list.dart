import 'package:flutter/material.dart';
import 'package:mobile_attendance/set_workplace.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkplaceList extends StatelessWidget {

  final TextEditingController textEditingController = TextEditingController();

  Future<SharedPreferences> getWorkplaceList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs;
  }



  @override
  Widget build(BuildContext context) {
    final prefs = getWorkplaceList();
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(future: prefs,
            builder: (context,AsyncSnapshot<SharedPreferences> snapshot){
          if(snapshot.hasData){
            if(snapshot.data!.getKeys().isEmpty){
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: height*0.3,),
                    Text('No workplace yet'),
                    ElevatedButton(onPressed: (){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>WorkplaceList()));
                    }, child: Text('Refresh')),
                    Spacer(),
                    NewWorkplace(textEditingController: textEditingController,height: height,),
                  ],
                ),
              );
            }

            List<Widget> workplaceList = <Widget>[];
            workplaceList.addAll(snapshot.data!.getKeys().map((e) => Tile(text: e)).toList());

            return Center(child:
            Column(
              children: [
                Expanded(
                  child: ListView(children: workplaceList
                    ,padding: EdgeInsets.all(8.0),
                  ),
                ),
                // Spacer(),
                SizedBox(height: 10),
                NewWorkplace(textEditingController: textEditingController,height: height,)
              ],
            ));
          }
          return CircularProgressIndicator();
        }),
      ),
    );
  }
}

class NewWorkplace extends StatelessWidget {
  const NewWorkplace({
    Key? key,
    required this.textEditingController,
    required this.height
  }) : super(key: key);

  final TextEditingController textEditingController;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.ltr,
      children: [

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Add a workplace'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Workplace Name'
            ),
            controller: textEditingController,
          ),
        ),
        Container(
          width: double.infinity,
          height: height*0.1,
          padding: EdgeInsets.all(8.0),
          child: ElevatedButton(onPressed: (){
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => WorkplaceScreen(workplaceName: textEditingController.text,)));
          }, child: Text('Add Workplace')),
        )
      ],
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
        child: Container(
          height: height*0.1,
          width: double.infinity,
          color: Colors.grey,
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text(this.text)),
        ),
      ),
    );
  }
}

