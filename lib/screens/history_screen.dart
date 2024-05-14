import 'package:driver/data_handler/app_data.dart';
import 'package:driver/widgets/history_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Journey History"),
        backgroundColor: Colors.cyan,
        leading: IconButton(
          onPressed: ()
          {
            Navigator.pop(context);
          },
          icon: Icon(Icons.keyboard_backspace_rounded),
        ),
      ),

      body:ListView.separated(
          padding: EdgeInsets.all(0),
          itemBuilder: (context,index)
          {
            return HistoryItem(history: Provider.of<AppData>(context,listen: false).tripHistoryDataList![index],);
          },
          separatorBuilder: (BuildContext context,int index) => Divider(thickness: 3,height: 3,),

          itemCount: Provider.of<AppData>(context,listen: false).tripHistoryDataList!.length,
      physics: ClampingScrollPhysics(),
        shrinkWrap: true,
      )
    );
  }
}
