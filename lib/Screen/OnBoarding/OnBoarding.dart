import 'package:flutter/material.dart';
import 'package:pubfix/Screen/welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // List of onboarding page data
    final List<OnboardingPageData> pages = [
      OnboardingPageData(
        image: const AssetImage("assets/images/OnBoarding/1.png"),
        title: "Améliorez votre quartier, une photo à la fois.",
        description:
            "Créer un compte PubFix et commencez à changer votre quartier dès aujourd'hui !",
      ),
      OnboardingPageData(
        image: const AssetImage("assets/images/OnBoarding/2.png"),
        title: " Votre voix compte",
        description:
            "Rejoignez la communauté PubFix et faites entendre votre voix ! ",
      ),
      OnboardingPageData(
        image: const AssetImage("assets/images/OnBoarding/3.png"),
        title: "Unissons nos forces pour un quartier meilleur.",
        description:
            "Connecter à PubFix et donnez un coup de pouce à votre quartier !",
      ),
      OnboardingPageData(
          image: const AssetImage("assets/images/OnBoarding/4.png"),
          title: "Connectez. Signalez. Agissez.",
          description:
              "Soumettre une demande et commencez à changer votre quartier dès maintenant !",
          buttonText: 'Commencer', // Replace with your desired button text
          onButtonPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WelcomeScreen(),
                ));
          } // Replace with your home screen navigation
          ),
    ];

    return SafeArea(
      child: Scaffold(
        body: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemCount: pages.length,
          itemBuilder: (context, index) {
            final pageData = pages[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //
                  Image(image: pageData.image),
                  const SizedBox(height: 32.0),
                  Text(
                    pageData.title,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    pageData.description,
                    style: const TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  Container(
                    child: Positioned(
                      bottom: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const WelcomeScreen())), // Skip button navigation
                            child: const Text('Passer'),
                          ),
                          Row(
                            children: [
                              for (int i = 0; i < pages.length; i++)
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: i == _currentPage ? 8.0 : 0.0),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 8.0,
                                    height: 8.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentPage == i
                                          ? const Color.fromARGB(
                                              255, 63, 79, 93)
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 16.0),
                              if (index == pages.length - 1)
                                ElevatedButton(
                                  onPressed: pageData
                                      .onButtonPressed, // Trigger action on "Get Started" or similar button
                                  child: Text(pageData.buttonText ??
                                      'Commencer'), // Use provided button text or default to "Done"
                                )
                              else
                                ElevatedButton(
                                  onPressed: () => _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.ease),
                                  child: const Text('Suivant'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class OnboardingPageData {
  // Image asset for the onboarding screen
  final AssetImage image;

  // Title text for the onboarding screen
  final String title;

  // Description text for the onboarding screen
  final String description;

  // Optional button text for the last page (default is "Done")
  final String? buttonText;

  // Optional callback function to be triggered when the button on the last page is pressed
  final VoidCallback? onButtonPressed;

  OnboardingPageData({
    required this.image,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
  });
}
