import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'task.dart';
import 'task_form.dart';

void main() {
  runApp(OrdenxApp());
}

class OrdenxApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ordenx',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          color: const Color.fromARGB(
              255, 156, 210, 255), // Color de fondo del AppBar
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadTasks() async {
    final tasks = await DatabaseHelper().getTasks();
    setState(() {
      _tasks = tasks.map((task) => Task.fromMap(task)).toList();
      _filteredTasks = _tasks;
    });
  }

  void _addTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskForm()),
    );
    if (result == true) {
      _loadTasks();
    }
  }

  void _editTask(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskForm(task: task)),
    );
    if (result == true) {
      _loadTasks();
    }
  }

  void _deleteTask(int id) async {
    await DatabaseHelper().deleteTask(id);
    _loadTasks();
  }

  void _onSearchChanged() {
    String searchTerm = _searchController.text.toLowerCase();
    setState(() {
      _filteredTasks = _tasks
          .where((task) =>
              task.name.toLowerCase().contains(searchTerm) ||
              task.description.toLowerCase().contains(searchTerm))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Orden a la X | Tu gestor de tareas',
          style: TextStyle(color: Colors.white), // Color del texto del AppBar
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TaskSearchDelegate(_tasks, _onSearchChanged),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          itemCount: _filteredTasks.length,
          itemBuilder: (context, index) {
            final task = _filteredTasks[index];
            return ListTile(
              title: Text(
                task.name,
                style: TextStyle(
                    color: Colors.white), // Color del texto del ListTile
              ),
              subtitle: Text(
                task.description,
                style: TextStyle(
                    color: Colors
                        .white70), // Color del texto del subtítulo del ListTile
              ),
              onTap: () => _editTask(task),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteTask(task.id!),
                color: Colors.white, // Color del icono del botón de eliminación
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: Icon(Icons.add),
      ),
    );
  }
}

class TaskSearchDelegate extends SearchDelegate<String> {
  final List<Task> tasks;
  final Function searchCallback;

  TaskSearchDelegate(this.tasks, this.searchCallback);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          searchCallback();
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredList = query.isEmpty
        ? tasks
        : tasks
            .where(
                (task) => task.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final task = filteredList[index];
        return ListTile(
          title: Text(task.name),
          onTap: () {
            query = task.name;
            searchCallback();
            close(context, query);
          },
        );
      },
    );
  }
}
