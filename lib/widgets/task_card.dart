import 'package:flutter/material.dart';
import 'package:helloworld/screens/task_list_screen.dart';

// TaskCard is a reusable widget that displays one task in the list.
// It is StatelessWidget — it receives everything it needs as parameters.
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;    // Called when the card is tapped
  final VoidCallback onToggle; // Called when the checkbox is toggled

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
  });

  // Color based on priority
  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':   return Colors.red;
      case 'Medium': return Colors.orange;
      default:       return Colors.green;
    }
  }

  // Icon based on category
  IconData _categoryIcon(String category) {
    switch (category) {
      case 'School':   return Icons.school;
      case 'Health':   return Icons.favorite;
      case 'Work':     return Icons.work;
      case 'Finance':  return Icons.attach_money;
      default:         return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    // A task is overdue if it's not done AND the due date is in the past
    final isOverdue = !task.isCompleted &&
                      task.dueDate.isBefore(DateTime.now());

    return GestureDetector(
      onTap: onTap, // Navigate to detail screen
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            // Highlight overdue tasks with a red border
            color: isOverdue ? Colors.red.shade300 : Colors.grey.shade200,
            width: isOverdue ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),

          // Left: colored priority indicator strip
          leading: Container(
            width: 5,
            height: 50,
            decoration: BoxDecoration(
              color: _priorityColor(task.priority),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Title with strikethrough when completed
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? Colors.grey : Colors.black87,
            ),
          ),

          // Subtitle: category icon + due date
          subtitle: Row(
            children: [
              Icon(_categoryIcon(task.category), size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                task.category,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.calendar_today,
                size: 12,
                color: isOverdue ? Colors.red : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                style: TextStyle(
                  fontSize: 12,
                  color: isOverdue ? Colors.red : Colors.grey,
                  fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),

          // Right: checkbox to toggle completion
          trailing: Checkbox(
            value: task.isCompleted,
            activeColor: Colors.teal,
            onChanged: (_) => onToggle(),
          ),
        ),
      ),
    );
  }
}
