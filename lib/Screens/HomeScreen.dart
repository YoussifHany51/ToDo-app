import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/Screens/addTask.dart';
import 'package:todo/models/task_models.dart';
import 'package:todo/helpers/database_helper.dart';

class HomeScreen extends StatefulWidget {
  // HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Task>> _taskList;

  final DateFormat _dateFormatter = DateFormat('MMM dd ,yyyy');

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList = DatabaseHelper.instance.getTaskList();
    });
  }

  void deletetask(int id) {
    DatabaseHelper.instance.deleteTask(id);
  }

  Widget deleteItem() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20),
      color: Colors.red,
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTask(Task task) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        // children: [
        //   Dismissible(
        //     key: UniqueKey(),
        //     onDismissed: (direction) {
        //       deletetask(task.id);
        //     },
        //     background: deleteItem(),
        children: [
          ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                  fontSize: 18,
                  decoration: task.status == 0
                      ? TextDecoration.none
                      : TextDecoration.lineThrough),
            ),
            subtitle: Text(
              '${_dateFormatter.format(task.date)} - ${task.priority}',
              style: TextStyle(
                  fontSize: 15,
                  decoration: task.status == 0
                      ? TextDecoration.none
                      : TextDecoration.lineThrough),
            ),
            trailing: Checkbox(
              onChanged: (value) {
                task.status = value ? 1 : 0;
                DatabaseHelper.instance.updateTask(task);
                _updateTaskList();
              },
              activeColor: Colors.red,
              value: task.status == 1 ? true : false,
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.red,
            child: Icon(Icons.add),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddTask(
                          updateTaskList: _updateTaskList,
                        )))),
        body: FutureBuilder(
            future: _taskList,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final int completedTaskCount = snapshot.data
                  .where((Task task) => task.status == 1)
                  .toList()
                  .length;
              return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  itemCount: 1 + snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Tasks',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              '$completedTaskCount of ${snapshot.data.length}',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                      );
                    }
                    return _buildTask(snapshot.data[index - 1]);
                  });
            }));
  }
}
