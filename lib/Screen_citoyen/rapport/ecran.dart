import 'package:flutter/material.dart';

class ecranTaille extends StatefulWidget {
  const ecranTaille({super.key});

  @override
  State<ecranTaille> createState() => _ecranTailleState();
}

class _ecranTailleState extends State<ecranTaille> {
  @override
  Widget build(BuildContext context) {
    // Récupère la hauteur totale de l'écran en pixels
    double screenHeight = MediaQuery.of(context).size.height;

    // Récupère la hauteur de la AppBar et du BottomAppBar si nécessaire
    double appBarHeight = kToolbarHeight + 10;
    double bottomAppBarHeight =
        80.0; // ou toute autre hauteur que vous utilisez

    // Calcule la hauteur disponible
    double availableHeight = screenHeight - appBarHeight - bottomAppBarHeight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Example'),
      ),
      body: Container(
        height: availableHeight,
        color: Colors.blue,
        child: Center(
          child: Text(
            'Available Height: $availableHeight',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(height: bottomAppBarHeight),
      ),
    );
  }
}
