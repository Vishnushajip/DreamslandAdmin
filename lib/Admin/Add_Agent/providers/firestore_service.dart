import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/user_form_provider.dart';

class FirestoreService {
  static Future<void> saveUserForm(UserFormModel model) async {
    final agentTrackerDoc = FirebaseFirestore.instance
        .collection('AGCREATION')
        .doc('ID');

    final DocumentSnapshot docSnapshot = await agentTrackerDoc.get();

    int currentNumber = 0;

    if (docSnapshot.exists) {
      currentNumber = docSnapshot['Lastid'] as int;
    } else {
      await agentTrackerDoc.set({'Lastid': 0});
    }

    int newNumber = currentNumber + 1;
    final String newAgentId = 'AG $newNumber';

    final agentsCollection = FirebaseFirestore.instance.collection('agents');
    await agentsCollection.doc(newAgentId).set({
      'AgentId': newAgentId,
      'NumericAgentId': newNumber,
      'Firstname': model.firstName,
      'Lastname': model.lastName,
      'Username': model.username,
      'Password': model.password,
      'Personaladdress': model.address,
      'Districtplace': model.district,
      'Age': model.age,
      'Contactnumber': model.contactNumber,
      'Whatsappnumber': model.whatsappNumber,
      'Allocatedlocations': model.allocatedLocations,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await agentTrackerDoc.update({'Lastid': newNumber});

    print("✅ Agent $newAgentId saved successfully.");
  }
}
