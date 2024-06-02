import 'package:flutter/material.dart';

class card1 extends StatefulWidget {
  const card1({super.key});

  @override
  State<card1> createState() => _card1State();
}

class _card1State extends State<card1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 167, 110, 110),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 100, // Définir la largeur souhaitée
                    height: 150, // Définir la hauteur souhaitée
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/2.png'),
                        fit: BoxFit.contain,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(
                      width: 10), // Espacement entre l'image et le ListTile
                  const Expanded(
                    child: ListTile(
                      title: Text('Votre texte ici'),
                      subtitle: Text(
                          ' Sous-titre ici Sous-titre ici Sous-titre ici \nSous-titre ici Sous-titre ici '),
                      leading: Icon(Icons
                          .info), // Vous pouvez remplacer ceci par une autre image ou icône
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 167, 110, 110),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 150, // Définir la largeur souhaitée
                    height: 150, // Définir la hauteur souhaitée
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/2.png'),
                        fit: BoxFit.contain,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(
                      width: 10), // Espacement entre l'image et le ListTile
                  const Expanded(
                    child: ListTile(
                      title: Text('Votre texte ici'),
                      subtitle: Text('Sous-titre ici'),
                      leading: Icon(Icons
                          .info), // Vous pouvez remplacer ceci par une autre image ou icône
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 167, 110, 110),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 150, // Définir la largeur souhaitée
                    height: 150, // Définir la hauteur souhaitée
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/2.png'),
                        fit: BoxFit.contain,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(
                      width: 10), // Espacement entre l'image et le ListTile
                  const Expanded(
                    child: ListTile(
                      title: Text('Votre texte ici'),
                      subtitle: Text('Sous-titre ici'),
                      leading: Icon(Icons
                          .info), // Vous pouvez remplacer ceci par une autre image ou icône
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 167, 110, 110),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 150, // Définir la largeur souhaitée
                    height: 150, // Définir la hauteur souhaitée
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/2.png'),
                        fit: BoxFit.contain,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(
                      width: 10), // Espacement entre l'image et le ListTile
                  const Expanded(
                    child: ListTile(
                      title: Text('Votre texte ici'),
                      subtitle: Text('Sous-titre ici'),
                      leading: Icon(Icons
                          .info), // Vous pouvez remplacer ceci par une autre image ou icône
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 167, 110, 110),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 150, // Définir la largeur souhaitée
                    height: 150, // Définir la hauteur souhaitée
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/2.png'),
                        fit: BoxFit.contain,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(
                      width: 10), // Espacement entre l'image et le ListTile
                  const Expanded(
                    child: ListTile(
                      title: Text('Votre texte ici'),
                      subtitle: Text('Sous-titre ici'),
                      leading: Icon(Icons
                          .info), // Vous pouvez remplacer ceci par une autre image ou icône
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 167, 110, 110),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 150, // Définir la largeur souhaitée
                    height: 150, // Définir la hauteur souhaitée
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/2.png'),
                        fit: BoxFit.contain,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(
                      width: 10), // Espacement entre l'image et le ListTile
                  const Expanded(
                    child: ListTile(
                      title: Text('Votre texte ici'),
                      subtitle: Text('Sous-titre ici'),
                      leading: Icon(Icons
                          .info), // Vous pouvez remplacer ceci par une autre image ou icône
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
