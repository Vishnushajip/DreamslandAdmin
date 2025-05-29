import 'package:dladmin/Admin/DashBoard/Pages/View/Property_Details.dart';
import 'package:dladmin/Admin/Update/Pages/UpdateBasic_Details.dart';
import 'package:dladmin/Admin/DashBoard/Verfied_Tabs/Confirm_Alert.dart';
import 'package:dladmin/Admin/DashBoard/Verfied_Tabs/verfied_docs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';

class VerifiedDocumentsScreen extends ConsumerWidget {
  final String status;
  const VerifiedDocumentsScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(propertyProvider(status));
    final isMobile = MediaQuery.of(context).size.width <= 800;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Requests',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: documentsAsync.when(
          loading:
              () => Center(
                child: LoadingAnimationWidget.inkDrop(
                  color: const Color.fromARGB(255, 5, 38, 95),
                  size: 60,
                ),
              ),
          error: (error, stack) => SizedBox.shrink(),
          data: (documents) {
            if (documents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.bellSlash,
                      color: Colors.grey.shade500,
                      size: 60,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No Requests Found',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final document = documents[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.bottomToTop,
                        child: PropertyDetailPage(property: document),
                        duration: Duration(milliseconds: 400),
                      ),
                    );
                  },
                  child: Tooltip(
                    message: "Click to view Property",
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            leading: Container(
                              width: isMobile ? 35 : 50,
                              height: isMobile ? 35 : 50,
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                document.propertyId,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                  fontSize: isMobile ? 6 : 10,
                                ),
                              ),
                            ),
                            title: Text(
                              document.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: isMobile ? 10 : 16,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  document.agent ?? 'No agent assigned',
                                  style: GoogleFonts.nunito(
                                    color: Colors.grey[600],
                                    fontSize: isMobile ? 8 : 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Posted On: ${DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(document.listedOn))}',
                                  style: GoogleFonts.nunito(
                                    color: Colors.blue[800],
                                    fontSize: isMobile ? 6 : 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (status != "Verified by Admin")
                                  _buildActionButton(
                                    context: context,
                                    icon: Icons.check,
                                    color: Colors.green,
                                    onPressed:
                                        () => DocumentHandler().handleAccept(
                                          context,
                                          document,
                                          ref,
                                          status,
                                        ),
                                  ),
                                const SizedBox(width: 8),
                                Tooltip(
                                  message: 'Edit Property Info',
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          CupertinoModalPopupRoute(
                                            builder:
                                                (context) =>
                                                    updatePropertyFormPage(
                                                      property: document,
                                                    ),
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        FontAwesomeIcons.penToSquare,
                                        size: 14,
                                        color: Colors.black,
                                      ),

                                      
                                    ),
                                  ),
                                ),
                                if (status != "Rejected by Admin")
                                  _buildActionButton(
                                    context: context,
                                    icon: Icons.close,
                                    color: Colors.red,
                                    onPressed:
                                        () => DocumentHandler().handleReject(
                                          context,
                                          document,
                                          ref,
                                          status,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final isMobile = MediaQuery.of(context).size.width <= 800;
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: isMobile ? 15 : 18),
        onPressed: onPressed,
        splashRadius: 20,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          minWidth: isMobile ? 26 : 36,
          minHeight: isMobile ? 26 : 36,
        ),
      ),
    );
  }
}
