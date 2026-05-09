import 'package:flutter/material.dart';
import 'package:helloworld/widgets/task_card.dart';
import 'task_detail_screen.dart';

// ─── Task Model ───────────────────────────────────────────────────────────────
// A Dart class that represents one task. Think of it as a blueprint.
// Every task you create will be an "instance" (object) of this class.
class Task {
  String title;
  String description;
  String category;   // e.g. School, Personal, Health
  String priority;   // Low, Medium, High
  DateTime dueDate;
  bool isCompleted;

  // Constructor — called when you do: Task(title: '...', ...)
  Task({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false, // defaults to false if not provided
  });
}

// ─── Task List Screen ─────────────────────────────────────────────────────────
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // The master list of all tasks
  final List<Task> _tasks = [];

  // Current filter: 'All', 'Pending', or 'Completed'
  String _filter = 'All';

  // Current sort: 'dueDate' or 'priority'
  String _sortBy = 'dueDate';

  // Search query — updated as the user types
  String _searchQuery = '';

  // Whether the search bar is currently visible
  bool _isSearching = false;

  // Controller reads whatever text the user types in the search field
  final TextEditingController _searchController = TextEditingController();

  // ── Computed property: returns the filtered + sorted + searched list ──
  List<Task> get _filteredTasks {
    // Step 1: Apply the All/Pending/Completed filter
    List<Task> result = _tasks.where((task) {
      if (_filter == 'Pending') return !task.isCompleted;
      if (_filter == 'Completed') return task.isCompleted;
      return true; // 'All' — keep everything
    }).toList();

    // Step 2: Apply search filter (case-insensitive)
    if (_searchQuery.isNotEmpty) {
      result = result.where((task) =>
        task.title.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Step 3: Sort the result
    result.sort((a, b) {
      if (_sortBy == 'dueDate') {
        // compareTo() returns negative if a < b, 0 if equal, positive if a > b
        return a.dueDate.compareTo(b.dueDate);
      } else {
        // Sort by priority: High → Medium → Low
        const order = {'High': 0, 'Medium': 1, 'Low': 2};
        return (order[a.priority] ?? 1).compareTo(order[b.priority] ?? 1);
      }
    });

    return result;
  }

  // ── Opens the bottom sheet to add or edit a task ──
  void _openTaskForm({Task? existing}) {
    // TextEditingControllers let us read and pre-fill form fields
    final titleController = TextEditingController(text: existing?.title ?? '');
    final descController  = TextEditingController(text: existing?.description ?? '');

    String selectedCategory = existing?.category ?? 'School';
    String selectedPriority = existing?.priority ?? 'Medium';
    DateTime selectedDate   = existing?.dueDate ?? DateTime.now().add(const Duration(days: 1));

    // Form key lets us validate all fields at once with _formKey.currentState!.validate()
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to grow taller (needed for keyboard)
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // StatefulBuilder gives the bottom sheet its own setState
        // so dropdowns and date picker can update without rebuilding the whole screen
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              // viewInsets.bottom pushes the sheet up when the keyboard opens
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        existing == null ? 'Add New Task' : 'Edit Task',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Title field
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                        // validator runs when we call formKey.currentState!.validate()
                        validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 12),

                      // Description field
                      TextFormField(
                        controller: descController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Description is required' : null,
                      ),
                      const SizedBox(height: 12),

                      // Category dropdown
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: ['School', 'Personal', 'Health', 'Work', 'Finance']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) => setSheetState(() => selectedCategory = val!),
                      ),
                      const SizedBox(height: 12),

                      // Priority dropdown
                      DropdownButtonFormField<String>(
                        initialValue: selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Low', 'Medium', 'High']
                            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (val) => setSheetState(() => selectedPriority = val!),
                      ),
                      const SizedBox(height: 12),

                      // Due date picker
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text(
                            'Due: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: const TextStyle(fontSize: 15),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () async {
                              // showDatePicker opens the system date picker dialog
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setSheetState(() => selectedDate = picked);
                              }
                            },
                            child: const Text('Change'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            // Validate all fields — if any validator returns a string, stop
                            if (!formKey.currentState!.validate()) return;

                            setState(() {
                              if (existing == null) {
                                // ADD: create a new Task and append it
                                _tasks.add(Task(
                                  title: titleController.text.trim(),
                                  description: descController.text.trim(),
                                  category: selectedCategory,
                                  priority: selectedPriority,
                                  dueDate: selectedDate,
                                ));
                              } else {
                                // EDIT: update the existing task's properties in-place
                                existing.title       = titleController.text.trim();
                                existing.description = descController.text.trim();
                                existing.category    = selectedCategory;
                                existing.priority    = selectedPriority;
                                existing.dueDate     = selectedDate;
                              }
                            });
                            Navigator.pop(context); // Close the bottom sheet
                          },
                          child: Text(existing == null ? 'Add Task' : 'Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Deletes all tasks after a confirmation dialog ──
  void _clearAllTasks() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Tasks?'),
        content: const Text('This will permanently delete all tasks.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _tasks.clear());
              Navigator.pop(ctx);
            },
            child: const Text('Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _filteredTasks; // computed list after filter/sort/search

    // Counts for the statistics bar
    final total     = _tasks.length;
    final completed = _tasks.where((t) => t.isCompleted).length;
    final pending   = total - completed;
    final progress  = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : const Text('My Tasks'),
        actions: [
          // Search toggle icon
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          // Sort icon
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (val) => setState(() => _sortBy = val),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'dueDate',  child: Text('Sort by Due Date')),
              const PopupMenuItem(value: 'priority', child: Text('Sort by Priority')),
            ],
          ),
          // Clear all icon
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearAllTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Statistics Bar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.teal.shade50,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statChip('Total', total, Colors.teal),
                    _statChip('Done', completed, Colors.green),
                    _statChip('Pending', pending, Colors.orange),
                  ],
                ),
                const SizedBox(height: 8),
                // LinearProgressIndicator fills from 0.0 to 1.0
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.teal,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% completed',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          // ── Filter Buttons ──
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['All', 'Pending', 'Completed'].map((f) {
                final isActive = _filter == f;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(f),
                    selected: isActive,
                    selectedColor: Colors.teal.shade100,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Task List ──
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          _filter == 'All' ? 'No tasks yet.\nTap + to add one!' : 'No $_filter tasks.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      // Dismissible enables left/right swipe gestures
                      return Dismissible(
                        key: ValueKey(task), // unique key required by Dismissible
                        direction: DismissDirection.endToStart, // swipe left only
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          setState(() => _tasks.remove(task));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('"${task.title}" deleted')),
                          );
                        },
                        child: TaskCard(
                          task: task,
                          onTap: () async {
                            // Navigate to detail screen, passing the task object
                            // We await the result in case the task was edited/deleted there
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TaskDetailScreen(task: task),
                              ),
                            );
                            // If detail screen deleted the task, remove it here too
                            if (result == 'deleted') {
                              setState(() => _tasks.remove(task));
                            } else if (result == 'edit') {
                              // Open the edit form pre-filled with this task
                              _openTaskForm(existing: task);
                            } else {
                              setState(() {}); // refresh if toggled
                            }
                          },
                          onToggle: () {
                            setState(() => task.isCompleted = !task.isCompleted);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // FloatingActionButton opens the add task form
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        onPressed: _openTaskForm,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper to build each stat badge in the statistics bar
  Widget _statChip(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}
