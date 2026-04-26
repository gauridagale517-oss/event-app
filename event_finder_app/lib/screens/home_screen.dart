import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Event>> futureEvents;

  List<Event> allEvents = [];
  List<Event> filteredEvents = [];

  @override
  void initState() {
    super.initState();
    futureEvents = ApiService.fetchEvents();
  }

  // 🔍 SEARCH FUNCTION
  void searchEvents(String query) {
    final results = allEvents.where((event) {
      final title = event.title.toLowerCase();
      final location = event.location.toLowerCase();
      final input = query.toLowerCase();

      return title.contains(input) || location.contains(input);
    }).toList();

    setState(() {
      filteredEvents = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Discover Events",
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(234, 219, 219, 1)),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purpleAccent, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: TextField(
              onChanged: searchEvents,
              decoration: const InputDecoration(
                hintText: "Search events...",
                prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Event>>(
              future: futureEvents,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Error loading events"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No events found"));
                }

                // ✅ STORE DATA
                allEvents = snapshot.data!;
                filteredEvents =
                    filteredEvents.isEmpty ? allEvents : filteredEvents;

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      futureEvents = ApiService.fetchEvents();
                      filteredEvents = [];
                    });
                  },
                  child: filteredEvents.isEmpty
                      ? const Center(child: Text("No events found"))
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                              top: 20, left: 15, right: 15),
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              // Adds 15 pixels of space at the bottom of every card
                              padding: const EdgeInsets.only(bottom: 12),
                              child: EventCard(
                                event: filteredEvents[index],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EventDetailScreen(
                                        event: filteredEvents[index],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
