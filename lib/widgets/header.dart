import 'package:flutter/material.dart';

class CalendarHeader extends StatelessWidget {
  final String title;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const CalendarHeader({
    Key? key,
    required this.title,
    required this.onPrevious,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 97, 64, 81),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(
              Icons.chevron_left,
              color: Color.fromARGB(255, 254, 254, 250),
              size: 28,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Color.fromARGB(255, 254, 254, 250),
              fontSize: 20.0,
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(
              Icons.chevron_right,
              color: Color.fromARGB(255, 254, 254, 250),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
