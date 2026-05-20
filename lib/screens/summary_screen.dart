import 'package:flutter/material.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  @override
  Widget build(BuildContext context) {
        
    return Scaffold(
      backgroundColor: const Color(0xFF121111),
      appBar: AppBar(
        backgroundColor: Colors.orange[400],
        title: const Text('Summary',
          style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600,color: Colors.white,),
        ),
        centerTitle: true,
      ),
      body: Padding(padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 30),),);
  }
}