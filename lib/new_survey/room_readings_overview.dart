import 'package:flutter/material.dart';
import 'package:iaqapp/models/survey_info.dart';
import 'package:iaqapp/new_survey/room_readings.dart';
import 'edit_room_reading.dart';

class RoomReadingsOverview extends StatefulWidget {
  final SurveyInfo surveyInfo;
  const RoomReadingsOverview({super.key, required this.surveyInfo});

  @override
  State<RoomReadingsOverview> createState() => _RoomReadingsOverviewState();
}

class _RoomReadingsOverviewState extends State<RoomReadingsOverview> {
  final TextEditingController _searchController = TextEditingController();

  List<RoomReading> _filteredReadings() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return roomReadings;
    return roomReadings.where((r) {
      return r.floorNumber.toLowerCase().contains(query) ||
          r.roomNumber.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredReadings();
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Room Readings'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by floor or room',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final reading = items[index];
                final listIndex = roomReadings.indexOf(reading);
                return ListTile(
                  title: Text(
                      'Floor ${reading.floorNumber} - Room ${reading.roomNumber}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditRoomReading(
                            index: listIndex,
                            roomReading: reading,
                            surveyInfo: widget.surveyInfo,
                          ),
                        ),
                      );
                      setState(() {});
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
