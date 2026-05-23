import 'package:day_flow/screens/activity_screen.dart';
import 'package:flutter/material.dart';

class SummaryScreen extends StatefulWidget {
  final List<Activity> activities;

  const SummaryScreen({super.key, required this.activities});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  List<Activity> get _activitiesForDate {
    return widget.activities.where((a) {
      return a.createdAt.year == _selectedDate.year &&
          a.createdAt.month == _selectedDate.month &&
          a.createdAt.day == _selectedDate.day;
    }).toList();
  }

  int get _totalCount => _activitiesForDate.length;
  int get _doneCount => _activitiesForDate.where((a) => a.isDone).length;
  int get _pendingCount => _totalCount - _doneCount;
  double get _completionRate =>
      _totalCount == 0 ? 0.0 : _doneCount / _totalCount;

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_currentMonth.year == now.year && _currentMonth.month == now.month) return;
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    List<DateTime> days = [];

    int weekdayOfFirst = firstDay.weekday % 7;
    for (int i = weekdayOfFirst - 1; i >= 0; i--) {
      days.add(firstDay.subtract(Duration(days: i + 1)));
    }

    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    int remaining = 42 - days.length;
    for (int i = 1; i <= remaining; i++) {
      days.add(DateTime(month.year, month.month + 1, i));
    }

    return days;
  }

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year &&
        day.month == now.month &&
        day.day == now.day;
  }

  bool _isSelected(DateTime day) {
    return day.year == _selectedDate.year &&
        day.month == _selectedDate.month &&
        day.day == _selectedDate.day;
  }

  bool _hasData(DateTime day) {
    return widget.activities.any((a) =>
        a.createdAt.year == day.year &&
        a.createdAt.month == day.month &&
        a.createdAt.day == day.day);
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatSelectedDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final isToday = _isToday(dt);
    final dateStr = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    return isToday ? 'Today — $dateStr' : dateStr;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _activitiesForDate;

    return Scaffold(
      backgroundColor: const Color(0xFF121111),
      appBar: AppBar(
        backgroundColor: Colors.orange[400],
        title: const Text('Daily Summary',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        // iconTheme: const IconThemeData(color: Colors.white),
        leading: GestureDetector(
          onTap: ()=> Navigator.pop(context),
          child: Padding(padding: EdgeInsets.all(12),
          child: Image.asset('assets/icons/back.png',height: 24,width: 24,color: Colors.white,colorBlendMode: BlendMode.srcIn,),),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendar(),
            const SizedBox(height: 20),

            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    color: Colors.orange, size: 15),
                const SizedBox(width: 8),
                Text(
                  _formatSelectedDate(_selectedDate),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (filtered.isEmpty)
              _buildEmptyState()
            else ...[
              _buildStatsRow(),
              const SizedBox(height: 20),

              _buildCompletionCard(),
              const SizedBox(height: 24),

              _buildCategoryBreakdown(filtered),
              const SizedBox(height: 24),

              const Text('Activities',
                style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _buildActivityTile(filtered[i]),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final days = _getDaysInMonth(_currentMonth);
    final monthYear ='${_getMonthName(_currentMonth.month)} ${_currentMonth.year}';
    final now = DateTime.now();
    final isCurrentMonth =_currentMonth.year == now.year && _currentMonth.month == now.month;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _previousMonth,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chevron_left_rounded,
                      color: Colors.white70, size: 20),
                ),
              ),
              Text(
                monthYear,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: _nextMonth,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isCurrentMonth ? Colors.transparent : Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: isCurrentMonth ? Colors.white24 : Colors.white70,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                          style:  TextStyle(color: Colors.orange[400],fontSize: 11,fontWeight: FontWeight.w500,),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 4,
              childAspectRatio: 1.0,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final day = days[index];
              final isCurrentMonthDay = day.month == _currentMonth.month;
              final today = _isToday(day);
              final selected = _isSelected(day);
              final hasData = _hasData(day) && isCurrentMonthDay;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDate = DateTime(day.year, day.month, day.day));
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: selected ? Colors.orange : today
                                ? Colors.orange.withValues(alpha: 0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: today && !selected? Border.all( color: Colors.orange.withValues(alpha: 0.6), width: 1.5): null,
                      ),
                      child: Center(
                        child: Text( '${day.day}',
                          style: TextStyle(fontSize: 13,fontWeight: selected || today ? FontWeight.bold : FontWeight.w400,
                            color: selected? Colors.white
                                : today? Colors.orange: isCurrentMonthDay? Colors.white70: Colors.white24,
                          ),
                        ),
                      ),
                    ),
                    if (hasData)
                      Positioned(
                        bottom: 4,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration( color: selected ? Colors.white : Colors.orange,shape: BoxShape.circle,),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total',
            value: '$_totalCount',
            icon: Icons.list_alt_rounded,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Done',
            value: '$_doneCount',
            icon: Icons.check_circle_rounded,
            color: Colors.greenAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Pending',
            value: '$_pendingCount',
            icon: Icons.pending_rounded,
            color: Colors.redAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionCard() {
    final percent = (_completionRate * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.3),
            Colors.orange.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Completion Rate',style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text('$percent%',
                style: const TextStyle(color: Colors.orange,fontSize: 22,fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _completionRate,
              minHeight: 10,
              backgroundColor: Colors.white12,
              color: _completionRate == 1.0 ? Colors.greenAccent : Colors.orange,
            ),
          ),
          const SizedBox(height: 10),
          Text( _completionRate == 1.0? 'All tasks completed for this day!'
                : '$_pendingCount task${_pendingCount > 1 ? 's' : ''} still pending.',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<Activity> activities) {
    final Map<String, int> total = {};
    final Map<String, int> done = {};

    for (final a in activities) {
      total[a.category] = (total[a.category] ?? 0) + 1;
      if (a.isDone) done[a.category] = (done[a.category] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('By Category',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...total.entries.map((entry) {
          final cat = entry.key;
          final catTotal = entry.value;
          final catDone = done[cat] ?? 0;
          final catProgress = catTotal == 0 ? 0.0 : catDone / catTotal;
          const color = Colors.grey;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding:const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.25)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(cat,style: const TextStyle(color: color,fontWeight: FontWeight.w600,fontSize: 13)),
                        ],
                      ),
                      Text('$catDone / $catTotal done',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: catProgress,
                      minHeight: 6,
                      backgroundColor: Colors.white10,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActivityTile(Activity activity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: activity.isDone ? Colors.grey : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: activity.isDone ? Colors.grey : Colors.white24,
                width: 2,
              ),
            ),
            child: activity.isDone ? const Icon(Icons.check_rounded, color: Colors.white, size: 13): null,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    color: activity.isDone ? Colors.white30 : Colors.white,
                    fontSize: 14,fontWeight: FontWeight.w500,decorationColor: Colors.white30,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(activity.category,
                        style: const TextStyle(color: Colors.grey,fontSize: 10,fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('·', style: TextStyle(color: Colors.white24)),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(activity.createdAt),
                      style:const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: activity.isDone
                  ? Colors.greenAccent.withValues(alpha: 0.12) : Colors.redAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              activity.isDone ? 'Done' : 'Pending',
              style: TextStyle(
                color: activity.isDone ? Colors.greenAccent : Colors.redAccent,
                fontSize: 11,fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: const [
            Icon(Icons.event_busy_rounded, color: Colors.white12, size: 64),
            SizedBox(height: 14),
            Text(
              'No activities found\nfor this date.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white30, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
            style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }
}