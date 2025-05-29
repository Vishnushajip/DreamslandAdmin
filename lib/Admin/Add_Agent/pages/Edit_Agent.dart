import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final loadingProvider = StateProvider<bool>((ref) => false);
final locationSuggestionsProvider = StateProvider<List<String>>((ref) => []);
final locationSearchLoadingProvider = StateProvider<bool>((ref) => false);

class AgentDetailPage extends ConsumerStatefulWidget {
  final String agentId;

  const AgentDetailPage({super.key, required this.agentId});

  @override
  ConsumerState<AgentDetailPage> createState() => _AgentDetailPageState();
}

class _AgentDetailPageState extends ConsumerState<AgentDetailPage> {
  late final TextEditingController firstNameController;
  late final TextEditingController agentIdController;
  late final TextEditingController lastNameController;
  late final TextEditingController usernameController;
  late final TextEditingController passwordController;
  late final TextEditingController addressController;
  late final TextEditingController districtController;
  late final TextEditingController ageController;
  late final TextEditingController contactNumberController;
  late final TextEditingController whatsappNumberController;
  late final TextEditingController locationsSearchController;

  List<String> allocatedLocations = [];
  bool _initialDataLoaded = false;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    agentIdController = TextEditingController();
    lastNameController = TextEditingController();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    addressController = TextEditingController();
    districtController = TextEditingController();
    ageController = TextEditingController();
    contactNumberController = TextEditingController();
    whatsappNumberController = TextEditingController();
    locationsSearchController = TextEditingController();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    agentIdController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    addressController.dispose();
    districtController.dispose();
    ageController.dispose();
    contactNumberController.dispose();
    whatsappNumberController.dispose();
    locationsSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (_initialDataLoaded) return;

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('agents')
          .doc(widget.agentId)
          .get();

      if (docSnapshot.exists) {
        final agentData = docSnapshot.data()!;
        firstNameController.text = agentData['Firstname'] ?? '';
        agentIdController.text = agentData['AgentId'] ?? '';
        lastNameController.text = agentData['Lastname'] ?? '';
        usernameController.text = agentData['Username'] ?? '';
        passwordController.text = agentData['Password'] ?? '';
        addressController.text = agentData['Personaladdress'] ?? '';
        districtController.text = agentData['Districtplace'] ?? '';
        ageController.text = agentData['Age']?.toString() ?? '';
        contactNumberController.text =
            agentData['Contactnumber']?.toString() ?? '';
        whatsappNumberController.text =
            agentData['Whatsappnumber']?.toString() ?? '';
        allocatedLocations =
            List<String>.from(agentData['Allocatedlocations'] ?? []);

        setState(() {
          _initialDataLoaded = true;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error loading agent data: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> fetchLocationSuggestions(String query) async {
    if (query.isEmpty) {
      ref.read(locationSuggestionsProvider.notifier).state = [];
      return;
    }

    ref.read(locationSearchLoadingProvider.notifier).state = true;

    try {
      final lowerQuery = query.toLowerCase();

      final snapshot = await FirebaseFirestore.instance
          .collection('property_location')
          .get();

      final suggestions = snapshot.docs
          .map((doc) => doc['location'] as String)
          .where((loc) =>
              loc.toLowerCase().contains(lowerQuery) &&
              !allocatedLocations.contains(loc))
          .take(5)
          .toList();

      ref.read(locationSuggestionsProvider.notifier).state = suggestions;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error fetching locations: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      ref.read(locationSearchLoadingProvider.notifier).state = false;
    }
  }

  Future<void> updateAgent() async {
    ref.read(loadingProvider.notifier).state = true;

    try {
      await FirebaseFirestore.instance
          .collection('agents')
          .doc(widget.agentId)
          .update({
        'Firstname': firstNameController.text,
        'AgentId': agentIdController.text,
        'Lastname': lastNameController.text,
        'Username': usernameController.text,
        'Password': passwordController.text,
        'Personaladdress': addressController.text,
        'Districtplace': districtController.text,
        'Age': ageController.text,
        'Contactnumber': contactNumberController.text,
        'Whatsappnumber': whatsappNumberController.text,
        'Allocatedlocations': allocatedLocations,
      });

      Fluttertoast.showToast(
        msg: "Agent updated successfully",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error updating agent: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  Future<void> addLocation(String location) async {
    if (location.trim().isEmpty ||
        allocatedLocations.contains(location.trim())) {
      return;
    }

    try {
      ref.read(loadingProvider.notifier).state = true;

      await FirebaseFirestore.instance
          .collection('agents')
          .doc(widget.agentId)
          .update({
        'Allocatedlocations': FieldValue.arrayUnion([location.trim()])
      });

      setState(() {
        allocatedLocations.add(location.trim());
      });

      locationsSearchController.clear();
      ref.read(locationSuggestionsProvider.notifier).state = [];
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error adding location: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  Future<void> removeLocation(String location) async {
    try {
      ref.read(loadingProvider.notifier).state = true;

      await FirebaseFirestore.instance
          .collection('agents')
          .doc(widget.agentId)
          .update({
        'Allocatedlocations': FieldValue.arrayRemove([location])
      });

      setState(() {
        allocatedLocations.remove(location);
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error removing location: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;
    final isLoading = ref.watch(loadingProvider);
    final locationSuggestions = ref.watch(locationSuggestionsProvider);
    final isSearching = ref.watch(locationSearchLoadingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Edit Agent',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder(
        future: _loadInitialData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !_initialDataLoaded) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.blue));
          }

          if (!_initialDataLoaded) {
            return const Center(child: Text('Failed to load agent data'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Personal Information',
                    style: GoogleFonts.nunito(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildResponsiveField(
                  isMobile,
                  _buildTextField('First Name', firstNameController),
                  _buildTextField('Last Name', lastNameController),
                ),
                _buildTextField('Agent ID', agentIdController, enabled: false),
                const SizedBox(height: 24),
                Text('Account Information',
                    style: GoogleFonts.nunito(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildResponsiveField(
                  isMobile,
                  _buildTextField('Username', usernameController),
                  _buildTextField('Password', passwordController,
                      isPassword: true),
                ),
                const SizedBox(height: 24),
                Text('Contact Information',
                    style: GoogleFonts.nunito(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildTextField('Personal Address', addressController),
                _buildResponsiveField(
                  isMobile,
                  _buildTextField('District', districtController),
                  _buildTextField('Age', ageController,
                      keyboardType: TextInputType.number),
                ),
                _buildResponsiveField(
                  isMobile,
                  _buildTextField('Contact Number', contactNumberController,
                      keyboardType: TextInputType.phone),
                  _buildTextField('WhatsApp Number', whatsappNumberController,
                      keyboardType: TextInputType.phone),
                ),
                const SizedBox(height: 24),
                Text('Location Allocation',
                    style: GoogleFonts.nunito(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: locationsSearchController,
                  decoration: InputDecoration(
                    hintText: 'Search locations...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: locationsSearchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () =>
                                addLocation(locationsSearchController.text),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  onChanged: fetchLocationSuggestions,
                ),
                const SizedBox(height: 8),
                if (isSearching)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                        child: CircularProgressIndicator(
                      color: Colors.blue,
                    )),
                  )
                else if (locationSuggestions.isNotEmpty)
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: locationSuggestions
                          .map((location) => ListTile(
                                title: Text(location),
                                trailing:
                                    const Icon(Icons.add, color: Colors.blue),
                                onTap: () => addLocation(location),
                              ))
                          .toList(),
                    ),
                  ),
                if (allocatedLocations.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allocatedLocations
                        .map((location) => Chip(
                              label: Text(location),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () => removeLocation(location),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 32),
                Center(
                  child: SizedBox(
                    width: isMobile ? double.infinity : 300,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : updateAgent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'SAVE CHANGES',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool isPassword = false,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.nunito(color: Colors.grey.shade600),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveField(bool isMobile, Widget field1, Widget field2) {
    if (isMobile) {
      return Column(children: [field1, field2]);
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: field1),
          const SizedBox(width: 16),
          Expanded(child: field2),
        ],
      );
    }
  }
}
