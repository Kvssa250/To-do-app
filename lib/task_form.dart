import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'task.dart';

class TaskForm extends StatefulWidget {
  final Task? task;

  TaskForm({this.task});

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _name = widget.task!.name;
      _description = widget.task!.description;
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (widget.task == null) {
        await DatabaseHelper()
            .insertTask({'name': _name, 'description': _description});
      } else {
        await DatabaseHelper().updateTask({
          'id': widget.task!.id,
          'name': _name,
          'description': _description,
        });
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Agregar tarea' : 'Editar tarea'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Tarea'),
                onSaved: (value) => _name = value!,
                validator: (value) => value!.isEmpty
                    ? 'Debes de asignarle un nombre a la tarea'
                    : null,
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Descripcion'),
                onSaved: (value) => _description = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTask,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
