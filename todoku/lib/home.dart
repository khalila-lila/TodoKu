import 'package:flutter/material.dart';
import 'api_service.dart';
import 'task.dart';
import 'add.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TaskModel> tasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() => _isLoading = true);
    try {
      final fetchedTasks = await ApiService.getTasks();
      setState(() => tasks = fetchedTasks);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading tasks: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateTaskStatus(TaskModel task) async {
    try {
      final updatedTask = TaskModel(
        id: task.id,
        title: task.title,
        priority: task.priority,
        dueDate: task.dueDate,
        isDone: !task.isDone,
      );
      await ApiService.updateTask(updatedTask);
      await _fetchTasks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update task: $e")),
      );
    }
  }

  Future<void> _deleteTask(int id) async {
    try {
      await ApiService.deleteTask(id);
      await _fetchTasks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete task: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do List"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTasks,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assignment, size: 60, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        "No tasks yet",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: _fetchTasks,
                        child: const Text("Refresh"),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isDone,
                          onChanged: (_) => _updateTaskStatus(task),
                          activeColor: Colors.teal,
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            decoration:
                                task.isDone ? TextDecoration.lineThrough : null,
                            fontWeight: FontWeight.w500,
                            color: task.isDone ? Colors.grey : Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.flag,
                                  size: 16,
                                  color: _getPriorityColor(task.priority),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  task.priority.capitalize(),
                                  style: TextStyle(
                                    color: _getPriorityColor(task.priority),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16),
                                const SizedBox(width: 4),
                                Text(task.dueDate),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTask(task.id!),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPage()),
          );
          if (added == true) await _fetchTasks();
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}