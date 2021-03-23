import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/models/task_models.dart';
import 'package:todo/helpers/database_helper.dart';

class AddTask extends StatefulWidget {
  // AddTask({Key key, Object object}) : super(key: key);
  final Task task;
  final Function updateTaskList;
  AddTask({this.task, this.updateTaskList});
  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _priority;
  DateTime _date = DateTime.now();

  TextEditingController _dateController = TextEditingController();

  final DateFormat _dateFormater = DateFormat('MMM dd, yyyy');
  final List<String> _priorities = ['Low', 'Medium', 'High'];
  @override
  void initState() {
    super.initState();


    if (widget.task != null) {
      _title = widget.task.title;
      _date = widget.task.date;
      _priority = widget.task.priority;
    }
    _dateController.text = _dateFormater.format(_date);
  }

  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  _handleDatePicker() async {
    final DateTime date = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormater.format(date);
    }
  }

  _delete() {
    DatabaseHelper.instance.deleteTask(widget.task.id);
    widget.updateTaskList();
    Navigator.pop(context);
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // print('$_title,$_date,$_priority');

      Task task = Task(title: _title, date: _date, priority: _priority);
      if (widget.task == null) {
        task.status = 0;
        DatabaseHelper.instance.insertTask(task);
      } else {
        task.id = widget.task.id;
        task.status = widget.task.status;
        DatabaseHelper.instance.updateTask(task);
      }
      widget.updateTaskList();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
                child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back_ios_outlined,
                        size: 30,
                        color: Colors.blueGrey[900],
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.task == null ? 'Add Task' : 'Update Task',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: TextFormField(
                              style: TextStyle(fontSize: 18),
                              decoration: InputDecoration(
                                labelText: 'Title',
                                labelStyle: TextStyle(fontSize: 18),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (input) => input.trim().isEmpty
                                  ? 'please entre a title'
                                  : null,
                              onSaved: (input) => _title = input,
                              initialValue: _title,
                            )),
                        Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: TextFormField(
                              readOnly: true,
                              controller: _dateController,
                              style: TextStyle(fontSize: 18),
                              onTap: _handleDatePicker,
                              decoration: InputDecoration(
                                labelText: 'Date',
                                labelStyle: TextStyle(fontSize: 18),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              textInputAction: TextInputAction.next,
                            )),
                        Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: DropdownButtonFormField(
                              isDense: true,
                              icon: Icon(Icons.arrow_drop_down_circle),
                              iconSize: 22,
                              iconEnabledColor: Colors.red,
                              items: _priorities.map((String priority) {
                                return DropdownMenuItem(
                                  child: Text(
                                    priority,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 18),
                                  ),
                                  value: priority,
                                );
                              }).toList(),
                              style: TextStyle(fontSize: 18),
                              decoration: InputDecoration(
                                labelText: 'Priority',
                                labelStyle: TextStyle(fontSize: 18),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (input) => input.trim().isEmpty
                                  ? 'please select a priority level'
                                  : null,
                              onSaved: (input) => _priority = input,
                              onChanged: (value) {
                                setState(() {
                                  _priority = value;
                                });
                              },
                              value: _priority,
                            )),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: FlatButton(
                            child: Text(
                              widget.task == null ? 'Add' : 'Update',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: _submit,
                          ),
                        ),
                        widget.task != null
                            ? Container(
                                margin: EdgeInsets.symmetric(vertical: 20),
                                height: 60,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: FlatButton(
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: _delete,
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              ),
            ))));
  }
}
