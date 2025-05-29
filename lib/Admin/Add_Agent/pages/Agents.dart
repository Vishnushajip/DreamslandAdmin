// ignore_for_file: unused_result

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dladmin/Admin/Add_Agent/pages/Edit_Agent.dart';
import 'package:dladmin/Admin/Add_Agent/pages/form_step1.dart';
import 'package:dladmin/Admin/Add_Agent/providers/user_form_provider.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../providers/allocated_locations.dart';

final agentsProvider =
    StateNotifierProvider<AgentsNotifier, List<DocumentSnapshot>>((ref) {
      return AgentsNotifier();
    });

class AgentsNotifier extends StateNotifier<List<DocumentSnapshot>> {
  AgentsNotifier() : super([]) {
    fetchNextBatch();
  }

  final int limit = 10;
  bool _isLoading = false;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  Future<void> fetchNextBatch() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;

    Query query = FirebaseFirestore.instance
        .collection('agents')
        .orderBy("createdAt")
        .limit(limit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
      state = [...state, ...snapshot.docs];
    }

    if (snapshot.docs.length < limit) {
      _hasMore = false;
    }

    _isLoading = false;
  }

  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
}

final sensitiveDataVisibilityProvider = StateProvider<Map<String, bool>>(
  (ref) => {},
);

final searchProvider = StateProvider<String>((ref) => '');

class AgentsListPage extends ConsumerStatefulWidget {
  const AgentsListPage({super.key});

  @override
  ConsumerState<AgentsListPage> createState() => _AgentsListPageState();
}

class _AgentsListPageState extends ConsumerState<AgentsListPage> {
  final ScrollController _scrollController = ScrollController();
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(agentsProvider.notifier).fetchNextBatch();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final agentsStream = ref.watch(agentsProvider);
    final searchQuery = ref.watch(searchProvider).toLowerCase();
    final sensitiveDataMap = ref.watch(sensitiveDataVisibilityProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Agents List',
          style: GoogleFonts.nunito(color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () {
                ref.refresh(userFormProvider);
                ref.refresh(locationSearchQueryProvider);
                ref.refresh(selectedLocationsProvider);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FormStep1()),
                );
              },
              child: Text(
                'Add Agent',
                style: GoogleFonts.nunito(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final agents = agentsStream;
          if (agents.isEmpty) {
            return const Center(child: Text('No agents found.'));
          }

          final filteredAgents =
              agents.where((agent) {
                final data = agent.data() as Map<String, dynamic>;
                final username =
                    (data['Username'] ?? '').toString().toLowerCase();
                final firstName =
                    (data['Firstname'] ?? '').toString().toLowerCase();
                return username.contains(searchQuery) ||
                    firstName.contains(searchQuery);
              }).toList();

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged:
                      (value) =>
                          ref.read(searchProvider.notifier).state = value,
                  decoration: InputDecoration(
                    suffixIcon:
                        ref.read(searchProvider).isNotEmpty
                            ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                ref.refresh(searchProvider);
                              },
                              icon: Icon(Icons.clear),
                            )
                            : null,
                    hintText: 'Search by Username or First Name',
                    prefixIcon: const Icon(Icons.search),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child:
                      filteredAgents.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  FontAwesomeIcons.userSlash,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No matching agents found.",
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            controller: _scrollController,
                            itemCount:
                                searchQuery.isEmpty
                                    ? filteredAgents.length + 1
                                    : filteredAgents.length,
                            itemBuilder: (context, index) {
                              if (index == filteredAgents.length) {
                                final hasMore =
                                    ref.read(agentsProvider.notifier).hasMore;
                                return hasMore
                                    ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: CircularProgressIndicator(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    )
                                    : const SizedBox.shrink();
                              }

                              final agent = filteredAgents[index];
                              final data = agent.data() as Map<String, dynamic>;
                              final agentId = agent.id;
                              final isSensitiveDataVisible =
                                  sensitiveDataMap[agentId] ?? false;
                              final List<dynamic> locations =
                                  data['Allocatedlocations'] ?? [];

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => AgentDetailPage(
                                                      agentId: agentId,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      CupertinoIcons
                                                          .person_alt_circle,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      data['Firstname'] ?? '',
                                                      style: GoogleFonts.nunito(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.blue,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                data['AgentId'] ?? '',
                                                style: GoogleFonts.nunito(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        _infoRow(
                                          "Locations",
                                          locations.join(', '),
                                          FontAwesomeIcons.locationArrow,
                                        ),
                                        _infoRow(
                                          "Contact Number",
                                          data['Contactnumber'],
                                          Icons.phone,
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                isSensitiveDataVisible
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                                color: Colors.black,
                                              ),
                                              onPressed: () {
                                                _showSensitiveDataDialog(
                                                  context,
                                                  data['Username'],
                                                  data['Password'],
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                CupertinoIcons.lock_circle,
                                                color: Colors.blue,
                                              ),
                                              onPressed:
                                                  () =>
                                                      _showChangePasswordDialog(
                                                        context,
                                                        agentId,
                                                      ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                CupertinoIcons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed:
                                                  () => _confirmDelete(
                                                    context,
                                                    agentId,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String? value, [IconData? prefixicon]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (prefixicon != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(prefixicon, size: 18),
            ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.nunito(color: Colors.black),
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: value ?? '-'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String agentId) async {
    bool shouldDelete = false;

    await AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      headerAnimationLoop: false,
      title: 'Delete Agent',
      desc: 'Are you sure you want to delete this agent?',
      btnCancelOnPress: () {
        shouldDelete = false;
      },
      btnOkOnPress: () {
        shouldDelete = true;
      },
      btnOkText: 'Delete',
      dialogBackgroundColor: Colors.white,
      btnOkColor: Colors.red,
      btnCancelText: 'Cancel',
      btnCancelColor: Colors.grey,
    ).show();

    if (shouldDelete) {
      await FirebaseFirestore.instance
          .collection('agents')
          .doc(agentId)
          .delete();
      Fluttertoast.showToast(
        msg: "Agent deleted successfully.",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }
  }

  void _showSensitiveDataDialog(
    BuildContext context,
    String? username,
    String? password,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              'Sensitive Data',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Username:',
                  style: GoogleFonts.nunito(color: Colors.black, fontSize: 16),
                ),
                Text(
                  username ?? 'N/A',
                  style: GoogleFonts.nunito(color: Colors.blue, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Text(
                  'Password:',
                  style: GoogleFonts.nunito(color: Colors.black, fontSize: 16),
                ),
                Text(
                  password ?? 'N/A',
                  style: GoogleFonts.nunito(color: Colors.blue, fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: GoogleFonts.nunito(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _showChangePasswordDialog(
    BuildContext context,
    String agentId,
  ) async {
    final TextEditingController passwordController = TextEditingController();

    final shouldChangePassword = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Change Password',
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter New Password',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.nunito(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Change',
                  style: GoogleFonts.nunito(color: Colors.blue),
                ),
              ),
            ],
          ),
    );

    if (shouldChangePassword == true && passwordController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('agents').doc(agentId).update(
        {'Password': passwordController.text},
      );

      Fluttertoast.showToast(
        msg: "Password changed successfully.",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }
  }
}
