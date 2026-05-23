import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:day_flow/models/activity.dart';

// class Activity extends HiveObject {
//   final String id;
//   String title;
//   String category;
//   bool isDone;
//   final DateTime createdAt;

//   Activity({
//     required this.id,
//     required this.title,
//     required this.category,
//     this.isDone = false,
//     required this.createdAt,
//   });
// }

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
   late Box<Activity> _box;

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'What to do', 'What you done'];

  final List<String> _categories = [
    'Study',
    'Learning',
    'Personal',
    'Work',
  ];

 List<Activity> get _filteredActivities {
    final all = _box.values.toList();
    if (_selectedFilter == 'What to do') {
      return all.where((a) => !a.isDone).toList();
    } else if (_selectedFilter == 'What you done') {
      return all.where((a) => a.isDone).toList();
    }
    return all;
  }

 int get _doneCount => _box.values.where((a) => a.isDone).length;

@override
void initState(){
  super.initState();
  _box = Hive.box<Activity>('activities');
}
  @override
  Widget build(BuildContext context) {
    final filtered = _filteredActivities;

    return Scaffold(
      backgroundColor: const Color(0xFF121111),
      appBar: AppBar(
  backgroundColor: Colors.deepPurple,
  title: const Text('Activity List',
    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
  ),
  centerTitle: true,
  leading: GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Image.asset('assets/icons/back.png',width: 24,height: 24,
        color: Colors.white,colorBlendMode: BlendMode.srcIn,
      ),
    ),
  ),
),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressCard(),
            const SizedBox(height: 20),

            Row(
              children: _filters.map((f) {
                final isSelected = f == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.deepPurple : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? Colors.deepPurple : Colors.white24,),
                      ),
                      child: Text(f,
                        style: TextStyle( color: isSelected ? Colors.white : Colors.white54,fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState() : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildActivityTile(filtered[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Activity',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildProgressCard() {
    final total = _box.values.length;
    final done = _doneCount;
    final progress = total == 0 ? 0.0 : done / total;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's Progress",
                style: TextStyle( color: Colors.white70,fontSize: 13),),
              Text(
                '$done / $total done',
                style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              color: Colors.greenAccent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progress == 1.0
                ? ' All tasks complete!': '${((progress) * 100).toInt()}% completed — keep going!',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(Activity activity) {
    return Dismissible(
      key: Key(activity.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        // child: const Icon(Icons.delete_rounded,
        //     color: Colors.redAccent, size: 28),
        child: Image.asset('assets/icons/delete.png',width: 18,height: 18,color: Colors.redAccent,       
        colorBlendMode: BlendMode.srcIn,),
      ),
      confirmDismiss: (_) async {
        _deleteActivity(activity.id);
        return false; 
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: activity.isDone ? Colors.white10: Colors.white10
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: (){
                activity.isDone = !activity.isDone;
                activity.save();
                setState(() {});
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: activity.isDone ? const Color.fromARGB(255, 255, 170, 0) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: activity.isDone ? const Color.fromARGB(255, 255, 170, 0) : Colors.white38,
                    width: 2,
                  ),
                ),
                child: activity.isDone ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: TextStyle(
                      color: activity.isDone? Colors.white30 : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      // decoration: activity.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                      decorationColor: Colors.white30,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric( horizontal: 2, vertical: 3),
                    child: Text(
                      '${_formatDateTime(activity.createdAt)} | ${activity.category}',
                      style: TextStyle( color: Colors.deepPurple, fontSize: 11, fontWeight: FontWeight.w600,),
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
  onPressed: () => _deleteActivity(activity.id),
  icon: Image.asset('assets/icons/delete.png',
    width: 18,height: 18,
    color: Colors.red[100],       
    colorBlendMode: BlendMode.srcIn,
  ),
),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, color: Colors.white12, size: 72),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'Done' ? 'No completed activities yet' : 'No activities here!\nTap + to add one.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white30, fontSize: 15),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    String selectedCategory = _categories.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(left: 24,right: 24,top: 24,bottom: MediaQuery.of(context).viewInsets.bottom + 24,),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Add New Activity',
                        style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold,),),
                      IconButton(
                        onPressed: ()=>Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: titleController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'What do you want to do?',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.edit_rounded,color: Colors.white38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Category',style: TextStyle(color: Colors.white60, fontSize: 13),),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = cat == selectedCategory;
                      final color =  Colors.grey;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.deepPurple : const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(20),
                           border: Border.all(color: isSelected ? Colors.deepPurple : Colors.white24,),
                          ),
                          child: Text(cat,
                            style: TextStyle(fontSize: 13,color: isSelected ? Colors.white : color,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
                      ),
                      onPressed: () {
                          final title = titleController.text.trim();
                          if (title.isEmpty) return;
                          final activity = Activity(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: title,
                          category: selectedCategory,
                          createdAt: DateTime.now(),
                        );
                          _box.put(activity.id, activity);
                            setState(() {});
                            Navigator.pop(context);
                          },
                      child: const Text('Add Activity',
                        style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _deleteActivity(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Activity?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text('This action cannot be undone.',
          style: TextStyle(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              // setState(() => _activities.removeWhere((a) => a.id == id));
              _box.delete(id);
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Delete',style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

String _formatDateTime(DateTime dt) {
  final date = '${dt.day.toString().padLeft(2, '0')}/''${dt.month.toString().padLeft(2, '0')}/''${dt.year}';
  final hour = dt.hour.toString().padLeft(2, '0');
  final min  = dt.minute.toString().padLeft(2, '0');
  return '$date  $hour:$min';
}
}