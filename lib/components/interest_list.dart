import 'package:flutter/material.dart';
import 'interest_card.dart';
import '/models/interests_model.dart';

class InterestList extends StatelessWidget {
  final List<Interests> items;
  final List<String> selectedInterests;
  final ValueChanged<String> onInterestToggle;
  final ValueChanged<String> onInterestDelete;

  const InterestList({
    Key? key,
    required this.items,
    required this.selectedInterests,
    required this.onInterestToggle,
    required this.onInterestDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedInterests.contains(item.title);
        return Column(
          children: [
            if (item.isOriginal)
              InterestCard(
                interest: item,
                isSelected: isSelected,
                onTap: () {
                  onInterestToggle(item.title);
                },
              ),
            if (!item.isOriginal)
              Dismissible(
                key: Key(item.title),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  onInterestDelete(item.title);
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: InterestCard(
                  interest: item,
                  isSelected: isSelected,
                  onTap: () {
                    onInterestToggle(item.title);
                  },
                ),
              ),
            SizedBox(height: 10), // Add vertical space between cards
          ],
        );
      },
    );
  }
}
