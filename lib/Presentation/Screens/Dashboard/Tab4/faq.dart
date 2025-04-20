import 'package:flutter/material.dart';
class FAQHelpScreen extends StatelessWidget {
  const FAQHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {"question": "How do I register for events?", "answer": "Go to Explore > Select event > Click Register."},
      {"question": "Where can I view my certificates?", "answer": "Check Portfolio > Click on any event."},
      {"question": "How to contact support?", "answer": "Go to Help > Use the contact form or email support."},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("FAQ's")),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.deepPurple, Colors.indigo]),
            ),
            child: const Text(
              "How can we help you?",
              style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...faqs.map((faq) => ExpansionTile(
            title: Text(faq['question']!),
            children: [Padding(padding: const EdgeInsets.all(16), child: Text(faq['answer']!))],
          )),
        ],
      ),
    );
  }
}
