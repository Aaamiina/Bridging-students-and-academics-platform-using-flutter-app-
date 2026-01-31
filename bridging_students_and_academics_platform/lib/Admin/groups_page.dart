import 'package:flutter/material.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  // ---------------- MOCK USERS ----------------
  final List<Map<String, String>> users = [
    {"name": "Ali Ahmed", "email": "ali@mail.com", "role": "Student"},
    {"name": "Amina Noor", "email": "amina@mail.com", "role": "Student"},
    {"name": "Hassan Omar", "email": "hassan@mail.com", "role": "Supervisor"},
    {"name": "Fatima Yusuf", "email": "fatima@mail.com", "role": "Student"},
  ];

  // ---------------- GROUP DATA ----------------
  final TextEditingController groupName = TextEditingController();
  final List<Map<String, dynamic>> groups = [];

  int? selectedGroupIndex;
  final List<String> selectedStudents = [];

  // ---------------- CREATE GROUP ----------------
  void createGroup() {
    if (groupName.text.isEmpty) return;

    setState(() {
      groups.add({
        "name": groupName.text,
        "members": <String>[],
      });
      groupName.clear();
    });
  }

  // ---------------- ASSIGN STUDENTS ----------------
  void assignStudents() {
    if (selectedGroupIndex == null) return;

    setState(() {
      groups[selectedGroupIndex!]["members"] =
          List<String>.from(selectedStudents);
      selectedStudents.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Groups Management",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          // ----------- CREATE GROUP -----------
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: groupName,
                    decoration: const InputDecoration(
                      labelText: "Group Name",
                      prefixIcon: Icon(Icons.groups),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F7F3B),
                      ),
                      onPressed: createGroup,
                      child: const Text("Create Group",style: TextStyle(color: Colors.white),),
                    ),
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ----------- GROUP LIST -----------
          const Text("Created Groups",
              style: TextStyle(fontWeight: FontWeight.bold)),

          SizedBox(
            height: 120,
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final g = groups[index];
                return Card(
                  child: ListTile(
                    title: Text(g["name"]),
                    subtitle: Text(
                        "Members: ${g["members"].isEmpty ? "None" : g["members"].length}"),
                    trailing: Icon(
                      selectedGroupIndex == index
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: Colors.green,
                    ),
                    onTap: () {
                      setState(() {
                        selectedGroupIndex = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const Divider(),

          // ----------- ASSIGN STUDENTS -----------
          const Text(
            "Assign Students",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          Expanded(
            child: ListView(
              children: users
                  .where((u) => u["role"] == "Student")
                  .map((student) {
                final selected =
                    selectedStudents.contains(student["email"]);
                return CheckboxListTile(
                  title: Text(student["name"]!),
                  subtitle: Text(student["email"]!),
                  value: selected,
                  onChanged: selectedGroupIndex == null
                      ? null
                      : (v) {
                          setState(() {
                            if (v == true) {
                              selectedStudents.add(student["email"]!);
                            } else {
                              selectedStudents.remove(student["email"]!);
                            }
                          });
                        },
                );
              }).toList(),
            ),
          ),

          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F7F3B),
              ),
              onPressed:
                  selectedGroupIndex == null ? null : assignStudents,
              child:  Text("Assign To Group" ,style: TextStyle(color: Colors.white),),
            ),
          ),
        ],
      ),
    );
  }
}
