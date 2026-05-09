import 'package:flutter/material.dart';
import 'task_list_screen.dart'; // Import Task class

// TaskDetailScreen receives a Task object and displays all its properties.
// It is StatefulWidget because the task's isCompleted state can change here.
class TaskDetailScreen extends StatefulWidget {
  final Task task; // The task passed in from the list screen

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  // Returns a color based on priority level
  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':   return Colors.red;
      case 'Medium': return Colors.orange;
      default:       return Colors.green; // Low
    }
  }

  // Returns an icon based on category
  IconData _categoryIcon(String category) {
    switch (category) {
      case 'School':   return Icons.school;
      case 'Health':   return Icons.favorite;
      case 'Work':     return Icons.work;
      case 'Finance':  return Icons.attach_money;
      default:         return Icons.person; // Personal
    }
  }

  // Shows a confirmation dialog before deleting
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to delete "${widget.task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);           // Close the dialog
              Navigator.pop(context, 'deleted'); // Go back, pass 'deleted' signal
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final task     = widget.task; // shorthand
    final isOverdue = !task.isCompleted &&
                      task.dueDate.isBefore(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with completion status
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      // Strikethrough if completed
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isCompleted ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
                // Priority badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _priorityColor(task.priority).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _priorityColor(task.priority)),
                  ),
                  child: Text(
                    task.priority,
                    style: TextStyle(
                      color: _priorityColor(task.priority),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Overdue warning
            if (isOverdue)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.red),
                    SizedBox(width: 8),
                    Text('This task is overdue!',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

            if (isOverdue) const SizedBox(height: 16),

            // Detail rows
            _detailRow(Icons.description, 'Description', task.description),
            _detailRow(_categoryIcon(task.category), 'Category', task.category),
            _detailRow(
              Icons.calendar_today,
              'Due Date',
              '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
            ),
            _detailRow(
              task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              'Status',
              task.isCompleted ? 'Completed' : 'Pending',
            ),

            const SizedBox(height: 32),

            // Mark complete / incomplete button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(task.isCompleted ? Icons.undo : Icons.check),
                label: Text(task.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: task.isCompleted ? Colors.orange : Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  setState(() => task.isCompleted = !task.isCompleted);
                },
              ),
            ),

            const SizedBox(height: 12),

            // Edit button — pops back to list and signals an edit via the task object
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit Task'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.teal,
                  side: const BorderSide(color: Colors.teal),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  // Pop back and signal 'edit' so the list screen opens the form
                  Navigator.pop(context, 'edit');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: one detail row with icon, label, value
  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
