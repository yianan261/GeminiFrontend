import 'package:flutter/material.dart';
import '/components/my_button.dart';
import '/services/update_interests.dart';

class OnboardingStep4 extends StatefulWidget {
  const OnboardingStep4({Key? key}) : super(key: key);

  @override
  _OnboardingStep4State createState() => _OnboardingStep4State();
}

class Interests {
  final String title;
  final String imagePath;

  const Interests({
    required this.title,
    required this.imagePath,
  });
}

class _OnboardingStep4State extends State<OnboardingStep4> {
  static List<Interests> _items = [
    Interests(title: 'Architecture', imagePath: 'assets/images/architecture.jpg'),
    Interests(title: 'Art & Culture', imagePath: 'assets/images/art_culture.jpg'),
    Interests(title: 'Food, Drink & Fun', imagePath: 'assets/images/food_drink_fun.jpg'),
    Interests(title: 'History', imagePath: 'assets/images/history.jpg'),
    Interests(title: 'Nature', imagePath: 'assets/images/nature.jpg'),
    Interests(title: 'Cool & Unique', imagePath: 'assets/images/cool_unique.jpg'),
  ];



  String otherInterest = "";

  List<String> _selectedInterests = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('WanderFinds'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select your interests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: _items.map((item) {
                  return ListTile(
                    leading: Image.asset(item.imagePath, width: 40, height: 40,fit: BoxFit.cover),
                    title: Text(item.title),
                    trailing: Checkbox(
                      value: _selectedInterests.contains(item.title),
                      onChanged: (isChecked) {
                        setState(() {
                          if (isChecked == true) {
                            _selectedInterests.add(item.title);
                          } else {
                            _selectedInterests.remove(item.title);
                          }
                        });
                      },
                      activeColor: Colors.blue, // Checkbox color when checked
                      checkColor: Colors.white, // Color of the checkmark
                    ),
                  );
                }).toList(),
              ),
            ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0), // Same vertical padding as card margin
          child: TextField(
            decoration: InputDecoration(
              hintText: "Enter other Interests",
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(50)
                )
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                otherInterest = value;
              }
            },
          )),
            SizedBox(height: 280),
            MyButton(text:"submit", onTap: () => {
              updateOnboardingStep4(context,_selectedInterests, otherInterest)
            },)
          ],
        ),
      ),
    );
  }
}
