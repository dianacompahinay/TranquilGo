import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        leading: Container(
          margin: const EdgeInsets.only(left: 10),
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: SizedBox(
              width: 30,
              height: 30,
              child: Image.asset(
                'assets/images/back-arrow.png',
                fit: BoxFit.contain,
                color: const Color(0xFF6C6C6C),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(26, 16, 26, 10),
        child: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTextStyle(
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text("Privacy Policy"),
            ),
            const SizedBox(height: 10),

            text("Last Updated April 01, 2025"),
            const SizedBox(height: 25),
            text(
              "This Privacy Notice describes how and why we might access, collect, store, use, and/or share your personal information when you use our services.",
            ),
            const SizedBox(height: 15),
            boldText("Questions or concerns?"),
            const SizedBox(height: 5),
            text(
              "Reading this Privacy Notice will help you understand your privacy rights and choices. If you do not agree with our policies and practices, please do not use our services. If you have any questions or concerns, please contact us at dpcompahinay@up.edu.ph.",
            ),
            const SizedBox(height: 20),

            // Section Title
            sectionTitle("1. WHAT INFORMATION DO WE COLLECT?"),
            const SizedBox(height: 15),

            text(
              "We collect personal information that you voluntarily provide to us when you register, express interest, participate in activities, or contact us.",
            ),
            const SizedBox(height: 10),

            text(
                "The personal information we collect may include the following:"),
            const SizedBox(height: 10),

            // Bulleted List
            bulletPoint("Names"),
            bulletPoint("Email addresses"),
            bulletPoint("Usernames"),
            bulletPoint("Passwords"),
            bulletPoint("Uploaded images"),

            const SizedBox(height: 10),

            boldText("Sensitive Information"),
            text(
                "We process the following categories of sensitive information with your consent:"),
            bulletPoint("Health data"),
            bulletPoint("Journal entries, notes, or other text inputs"),

            const SizedBox(height: 10),

            boldText("Application Data"),
            text(
              "If you use our application, we may collect the following information if you provide us access or permission:",
            ),
            const SizedBox(height: 10),

            bulletItalizedTitle("Geolocation Information",
                "We may request permission to track location-based data for certain services. You can manage permissions in your device settings."),
            const SizedBox(height: 10),
            bulletItalizedTitle("Mobile Device Access",
                "We may request access to your camera, sensors, storage, photos, and other features. You can adjust these permissions in your device settings."),

            const SizedBox(height: 10),
            text(
                "This information is primarily needed to maintain the security and operation of our application, for troubleshooting, and for our internal analytics and reporting purposes."),

            const SizedBox(height: 20),

            boldText("Information Automatically Collected"),
            const SizedBox(height: 10),

            text(
                "We automatically collect certain information when you visit, use, or navigate our services. This may include general usage data, such as location, timestamps, and interactions with our services. Your name and email may be visible to other users when necessary for certain features, but we do not share your personal information with third parties. This information is mainly used to keep our services running smoothly and to help us understand how they are used."),
            const SizedBox(height: 10),
            text("The information we collect includes:"),
            const SizedBox(height: 10),

            bulletItalizedTitle(
              "Log and Usage Data",
              "We collect basic usage data when you access TranquilGo, depending on how you interact with us, this log data may include information about your activity in the Services (such as the date/time stamps associated with your usage, pages and files viewed, and other actions you take such as which features you use), device event information.",
            ),

            const SizedBox(height: 10),
            bulletItalizedTitle(
              "Location Data",
              "The app collects location data such as information about your device's location, which can be either precise or imprecise. This data is processed on your device and is not collected or stored by us, it is used to track your walking routes and provide route suggestions. You can opt out of allowing us to collect this information either by refusing access to the information or by disabling your Location setting on your device. However, if you choose to opt out, you may not be able to use certain aspects of the Services.",
            ),

            const SizedBox(height: 20),
            boldText("Google API"),
            const SizedBox(height: 10),
            text(
              "Our use of information received from Google APIs will adhere to Google API Services User Data Policy, including the Limited Use requirements.",
            ),
            const SizedBox(height: 20),

            sectionTitle("2. HOW DO WE PROCESS YOUR INFORMATION?"),
            const SizedBox(height: 10),
            text(
              "We process your personal information for a variety of reasons depending on how you interact with our services, including:",
            ),
            const SizedBox(height: 10),

            bulletBoldTitle(
              "To facilitate account creation and authentication",
              "We may process your information so you can create and log in to your account, as well as keep your account in working order.",
            ),
            const SizedBox(height: 5),
            bulletBoldTitle(
              "To deliver and facilitate services",
              "We may process your information to provide you with the requested service.",
            ),
            const SizedBox(height: 5),
            bulletBoldTitle(
              "To enable user-to-user communications",
              "We may process your information if you choose to use any of our offerings that allow for communication with another user.",
            ),

            const SizedBox(height: 5),
            bulletBoldTitle(
              "To provide progress reports.",
              "We may generate summaries of your activity, including distance walked, number of steps, and overall progress, to help you track your fitness goals.",
            ),
            const SizedBox(height: 20),

            sectionTitle(
                "3. WHEN AND WITH WHOM DO WE SHARE YOUR PERSONAL INFORMATION?"),
            const SizedBox(height: 10),
            text("However, we may share data with:"),
            const SizedBox(height: 10),
            boldText("Third-Party Service Providers."),
            text(
              "We may use third-party services to support certain app features, such as analytics, media storage, GPS tracking, and database management. However, we do not directly share personal data with these providers, nor do we have direct control over how they handle data. If any third-party services are used, they are responsible for processing data according to their own privacy policies.",
            ),
            const SizedBox(height: 10),

            text(
                "The third parties we may share personal information with are as follows:"),
            const SizedBox(height: 10),

            bulletBoldTitle("Web and mobile analytics", "Google Analytics"),
            const SizedBox(height: 5),
            bulletBoldTitle("Media upload and storage", "Cloudinary"),
            const SizedBox(height: 5),
            bulletBoldTitle("GPS tracking", "Geolocation Services"),
            const SizedBox(height: 5),
            bulletBoldTitle("Database storage", "Firebase Firestore"),
            const SizedBox(height: 10),

            text(
                "We also may need to share your personal information in the following situations:"),
            const SizedBox(height: 10),

            bulletBoldTitle(
              "When we use Google Maps Platform APIs",
              "We may share your information with certain Google Maps Platform APIs (e.g., Google Maps API, Places API). Google Maps uses GPS, Wi-Fi, and cell towers to estimate your location. GPS is accurate to about 20 meters, while Wi-Fi and cell towers help improve accuracy when GPS signals are weak, like indoors. This data helps Google Maps provide directions, but it is not always perfectly precise. We obtain and store on your device (\"cache\") your location. You may revoke your consent anytime by contacting us at the contact details provided at the end of this document.",
            ),
            const SizedBox(height: 10),
            bulletBoldTitle(
              "Other Users",
              "When you share personal information or otherwise interact with public areas of the Services, such personal information may be viewed by all users and may be publicly made available outside the Services in perpetuity. Similarly, other users will be able to view descriptions of your activity, communicate with you within our Services, and view your profile.",
            ),
            const SizedBox(height: 20),

            sectionTitle("4. DO WE USE COOKIES AND TRACKING TECHNOLOGIES?"),
            const SizedBox(height: 10),

            text(
                "We do not use cookies, web beacons, or similar tracking technologies typically found on websites. However, third-party services integrated into the app, such as analytics or cloud storage providers, may use tracking technologies to collect usage data for performance monitoring and improvements. We do not use tracking technologies for advertising or personalized marketing."),
            const SizedBox(height: 20),

            boldText("Google Analytics"),
            const SizedBox(height: 5),
            text(
                "We may share your information with Google Analytics to track and analyze the use of the Services. To opt out of being tracked by Google Analytics across the Services, visit https://tools.google.com/dlpage/gaoptout. For more information on the privacy practices of Google, please visit the Google Privacy & Terms page."),

            const SizedBox(height: 20),

            sectionTitle(
                "5. DO WE OFFER ARTIFICIAL INTELLIGENCE-BASED PRODUCTS?"),
            const SizedBox(height: 10),
            text(
                "We do not currently use artificial intelligence (AI) or machine learning technologies to process user data or provide features. If AI-powered tools are introduced in the future, we will update this Privacy Notice accordingly."),
            const SizedBox(height: 20),

            sectionTitle("6. HOW LONG DO WE KEEP YOUR INFORMATION?"),
            const SizedBox(height: 10),
            text(
                "We retain your personal information only for as long as necessary to provide our services. When you delete your account, all associated personal information will be deleted and will not be retained in backups."),

            const SizedBox(height: 20),

            sectionTitle("7. WHAT ARE YOUR PRIVACY RIGHTS?"),
            const SizedBox(height: 10),
            boldText("Withdrawing your consent:"),
            text(
                "If we are relying on your consent to process your personal information, which may be express and/or implied consent depending on the applicable law, you have the right to withdraw your consent at any time. You can withdraw your consent at any time by contacting us by using the contact details provided in the section \"HOW CAN YOU CONTACT US ABOUT THIS NOTICE?\" below."),
            const SizedBox(height: 10),
            text(
                "Please note that this will not affect any processing done before you withdraw your consent, and some features of the app may no longer work without it."),
            const SizedBox(height: 10),

            sectionTitle("Account Information"),
            const SizedBox(height: 5),
            text(
                "If you would at any time like to review or change the information in your account or terminate your account, you can:"),
            const SizedBox(height: 10),
            bulletPoint("Delete your account by contacting us"),
            const SizedBox(height: 5),
            bulletPoint("Update your account settings within the app"),
            const SizedBox(height: 10),

            text(
                "Upon your request to terminate your account, we will deactivate or delete your account and information from our active databases."),

            const SizedBox(height: 20),

            sectionTitle(
                "8. HOW CAN YOU REVIEW, UPDATE, OR DELETE THE DATA WE COLLECT FROM YOU?"),
            const SizedBox(height: 10),
            text(
              "You have the right to request access, corrections, or deletion of your data. Contact us to submit a data subject access request.",
            ),
            const SizedBox(height: 20),

            sectionTitle("9. HOW CAN YOU CONTACT US ABOUT THIS NOTICE?"),
            const SizedBox(height: 10),
            text(
                "If you have any inquiries or feedback regarding this notice, you can reach us via email at dpcompahinay@up.edu.ph or call us at 09615121467."),
            const SizedBox(height: 20),
            text("University of the Philippines Los Baños"),
            text("Los Baños, Laguna"),
            text("Philippines"),
            const SizedBox(height: 20),

            text(
                "By using TranquilGo, you agree to the terms of this Privacy Policy"),
            const SizedBox(height: 20),
            italicText(
                "This Terms and Conditions page was generated with the help of Termly. For more information, visit Termly's website at termly.io."),
            const SizedBox(height: 20),
          ],
        )),
      ),
    );
  }

  Widget text(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13.5,
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget boldText(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14.5,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget italicText(String text) {
    return Text(text, style: GoogleFonts.inter(fontStyle: FontStyle.italic));
  }

  Widget bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Text(
        "• $text",
        style: GoogleFonts.inter(
          fontSize: 13.5,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget boldBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Text(
        "• $text",
        style: GoogleFonts.inter(
          fontSize: 13.5,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget bulletItalizedTitle(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(
            fontSize: 13.5,
            color: Colors.black87,
          ),
          children: [
            TextSpan(
              text: "• $title. ",
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            TextSpan(text: description, style: const TextStyle(height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget bulletBoldTitle(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13.5, color: Colors.black87),
          children: [
            TextSpan(
              text: "• $title. ",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            TextSpan(text: description, style: const TextStyle(height: 1.4)),
          ],
        ),
      ),
    );
  }
}
