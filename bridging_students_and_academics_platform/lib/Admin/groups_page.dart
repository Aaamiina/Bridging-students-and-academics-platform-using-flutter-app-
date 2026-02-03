import 'package:bridging_students_and_academics_platform/controllers/admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupsPage extends StatelessWidget {
  GroupsPage({super.key});

  final AdminController controller = Get.find<AdminController>();
  final TextEditingController groupNameController = TextEditingController();
  final Color brandGreen = const Color(0xFF4A6D3F);

  // Local state for selection
  final RxnString selectedGroupId = RxnString();
  final RxList<String> selectedStudentEmails = <String>[].obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Groups Management",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: brandGreen),
            ),
            const SizedBox(height: 15),

            // ----------- CREATE GROUP -----------
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: groupNameController,
                      decoration: InputDecoration(
                        labelText: "Group Name",
                        labelStyle: TextStyle(color: brandGreen),
                        prefixIcon: Icon(Icons.groups, color: brandGreen),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: brandGreen)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: Obx(() => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: controller.isLoading.value ? null : () {
                          if (groupNameController.text.isNotEmpty) {
                            controller.createGroup(groupNameController.text);
                            groupNameController.clear();
                          }
                        },
                        child: controller.isLoading.value 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : const Text("Create Group", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ----------- GROUP LIST -----------
            Text("Select a Group to Assign Members",
                style: TextStyle(fontWeight: FontWeight.bold, color: brandGreen)),
            const SizedBox(height: 10),

            SizedBox(
              height: 150,
              child: Obx(() {
                if (controller.groups.isEmpty) return const Center(child: Text("No groups found"));
                
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.groups.length,
                  itemBuilder: (context, index) {
                    final g = controller.groups[index];
                    final gId = g['_id'];
                    final gName = g['name'] ?? 'Unnamed';
                    final mCount = g['memberCount'] ?? 0;

                    return Obx(() {
                      bool isSelected = selectedGroupId.value == gId;
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () => selectedGroupId.value = gId,
                            child: Container(
                              width: 140,
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: isSelected ? brandGreen : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: brandGreen.withOpacity(0.3)),
                                boxShadow: isSelected ? [BoxShadow(color: brandGreen.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(isSelected ? Icons.check_circle : Icons.group_work, color: isSelected ? Colors.white : brandGreen, size: 30),
                                  const SizedBox(height: 10),
                                  Text(
                                    gName, 
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "$mCount members", 
                                    style: TextStyle(
                                      color: isSelected ? Colors.white70 : Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 15,
                            child: InkWell(
                              onTap: () => _confirmDeleteGroup(context, gId, gName),
                              child: Icon(Icons.close, size: 18, color: isSelected ? Colors.white70 : Colors.red.withOpacity(0.7)),
                            ),
                          ),
                        ],
                      );
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 25),
            const Divider(),
            const SizedBox(height: 15),

            // ----------- ASSIGN STUDENTS -----------
            Obx(() {
               if (selectedGroupId.value == null) {
                 return Center(
                   child: Column(
                     children: [
                       Icon(Icons.touch_app, size: 50, color: brandGreen.withOpacity(0.2)),
                       const SizedBox(height: 10),
                       Text("Select a group above to start assigning", style: TextStyle(color: Colors.grey.shade400)),
                     ],
                   ),
                 );
               }
               
               return Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Assign Students",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: brandGreen),
                      ),
                      Text(
                        "${selectedStudentEmails.length} selected",
                        style: TextStyle(color: brandGreen, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (controller.students.isEmpty) 
                    const Center(child: Text("No students available"))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.students.length,
                      itemBuilder: (context, index) {
                        final s = controller.students[index];
                        final email = s['email'];
                        final name = s['name'];
                        final String? userGroup = s['group'];
                        final bool hasGroup = userGroup != null && userGroup.trim().isNotEmpty;

                        return Obx(() {
                          final isSelected = selectedStudentEmails.contains(email);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: Icon(
                                hasGroup ? Icons.lock : (isSelected ? Icons.check_box : Icons.check_box_outline_blank),
                                color: hasGroup ? Colors.grey : brandGreen,
                              ),
                              title: Text(name, style: TextStyle(color: hasGroup ? Colors.grey : Colors.black87)),
                              subtitle: Text(
                                hasGroup ? "Already in: $userGroup" : email,
                                style: TextStyle(color: hasGroup ? Colors.red.withOpacity(0.5) : Colors.grey),
                              ),
                              trailing: hasGroup 
                                ? IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.deepOrange),
                                    onPressed: () => controller.removeStudentFromGroup(s['_id']),
                                  )
                                : null,
                              onTap: hasGroup ? null : () {
                                if (isSelected) {
                                  selectedStudentEmails.remove(email);
                                } else {
                                  selectedStudentEmails.add(email);
                                }
                              },
                            ),
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: selectedStudentEmails.isEmpty || controller.isLoading.value
                            ? null 
                            : () async {
                                await controller.assignStudents(selectedGroupId.value!, selectedStudentEmails.toList());
                                selectedStudentEmails.clear();
                            },
                        child: controller.isLoading.value 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("CONFIRM ASSIGNMENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                 ],
               );
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteGroup(BuildContext context, String gId, String gName) {
    Get.defaultDialog(
      title: "Delete Group?",
      middleText: "Are you sure you want to delete '$gName'? This will unassign all students from this group but won't delete the users.",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.deleteGroup(gId);
        selectedGroupId.value = null;
      }
    );
  }
}
