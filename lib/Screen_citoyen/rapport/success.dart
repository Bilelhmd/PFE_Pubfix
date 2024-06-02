import 'package:flutter/material.dart';

class SuccessSubmittion extends StatefulWidget {
  const SuccessSubmittion({super.key});

  @override
  State<SuccessSubmittion> createState() => _SuccessSubmittionState();
}

class _SuccessSubmittionState extends State<SuccessSubmittion> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('congratulation'),
      ),
      body: const Column(
        children: [
          Image(
            image: AssetImage("assets/images/hello.png"),
          ),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}
