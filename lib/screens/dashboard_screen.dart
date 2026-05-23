
import 'package:day_flow/screens/activity_screen.dart';
import 'package:day_flow/screens/summary_screen.dart';
import 'package:day_flow/screens/timer_screen.dart';
import 'package:flutter/material.dart';

class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({super.key});
  
  List<Activity> get _activities => [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121111),
      appBar: AppBar(
        // backgroundColor: Colors.deepPurpleAccent,
        backgroundColor: Colors.white,
        title: const Text('Daily Activities',
          style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600,color: Colors.black,),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
            Positioned.fill(
            child: Image.asset('assets/icons/home.jpg',fit: BoxFit.cover,),
         ),

     Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('What would you like to do?',style: TextStyle(color: Colors.white70,fontSize: 16,),),
              const SizedBox(height: 24),
              _DashboardCard(
                // icon: Icons.checklist_rounded,
                icon: 'assets/icons/list.png',
                title: 'Activities List',
                subtitle: 'View and manage your daily tasks',
                color: Colors.deepPurple,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder:(context) => ActivityScreen()));
                },
              ),
              const SizedBox(height: 16),
        
              _DashboardCard(
                icon: 'assets/icons/timer.png',
                title: 'Study Timer',
                subtitle: 'Focus with a countdown timer',
                color: Colors.teal,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder:(context) => StudyTimerScreen()));
                },
              ),
              const SizedBox(height: 16),
        
              _DashboardCard(
                icon: 'assets/icons/summary.png',
                title: 'Daily Summary',
                subtitle: 'Track your progress for today',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder:(context) => SummaryScreen(activities: _activities)));
                },
              ),
            ],
          ),
        ),
        ]
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              // child: Icon(icon, color: color, size: 28),
              child: Image.asset(icon,height: 28,width: 28,
              colorBlendMode: BlendMode.srcIn,color: color,),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white,fontSize: 17,fontWeight: FontWeight.w600,),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.5), fontSize: 13,),
                  ),
                ],
              ),
            ),
             Image.asset('assets/icons/right_arrow.png',height: 15.5,width: 15.5,
              colorBlendMode: BlendMode.srcIn,color: color,)
          ],
        ),
      ),
    );
  }
}