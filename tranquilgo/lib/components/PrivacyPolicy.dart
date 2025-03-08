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

            text("Last Updated March 01, 2025"),
            const SizedBox(height: 25),
            text(
              "This Privacy Notice describes how and why we might access, collect, store, use, and/or share your personal information when you use our services, including when you:",
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

            // Bold Heading with Description
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
                "We automatically collect certain information when you visit, use, or navigate the services. This information does not reveal your specific identity (like your name or contact information) but may include device and usage information, such as your IP address, device characteristics, operating system, language preferences, reffering URLs, device name, country, location, information about how and when you use our services, and other technical information. This information is primarily needed to maintain the security and operation of our services, and for our internal analytics and reporting purposes."),
            const SizedBox(height: 10),
            text("The information we collect includes:"),
            const SizedBox(height: 10),

            bulletItalizedTitle(
              "Log and Usage Data",
              "Log and usage data is service-related, diagnostic, usage, and performance information our servers automatically collect when you access or use our Services and which we record in log files. Depending on how you interact with us, this log data may include your IP address, device information, browser type, and settings and information about your activity in the Services (such as the date/time stamps associated with your usage, pages and files viewed, searches, and other actions you take such as which features you use), device event information (such as system activity, error reports (sometimes called \"crash dumps\"), and hardware settings).",
            ),
            const SizedBox(height: 10),
            bulletItalizedTitle(
              "Device Data",
              "We collect device data such as information about your computer, phone, tablet, or other device you use to access the Services. Depending on the device used, this device data may include information such as your IP address (or proxy server), device and application identification numbers, location, browser type, hardware model, Internet service provider and/or mobile carrier, operating system, and system configuration information.",
            ),
            const SizedBox(height: 10),
            bulletItalizedTitle(
              "Location Data",
              "We collect location data such as information about your device's location, which can be either precise or imprecise. How much information we collect depends on the type and settings of the device you use to access the Services. For example, we may use GPS and other technologies to collect geolocation data that tells us your current location (based on your IP address). You can opt out of allowing us to collect this information either by refusing access to the information or by disabling your Location setting on your device. However, if you choose to opt out, you may not be able to use certain aspects of the Services.",
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
              "To protect our services",
              "We may process your information as part of our efforts to keep our services safe and secure, incliding fraud monitoring and prevention.",
            ),
            const SizedBox(height: 5),
            boldBulletPoint("To enhance social interactions."),
            const SizedBox(height: 5),
            boldBulletPoint("To improve mental wellness support."),
            const SizedBox(height: 5),
            boldBulletPoint(
                "To analyze step count accuracy and optimize tracking."),
            const SizedBox(height: 5),
            boldBulletPoint("To provide progress reports."),
            const SizedBox(height: 20),

            sectionTitle(
                "3. WHEN AND WITH WHOM DO WE SHARE YOUR PERSONAL INFORMATION?"),
            const SizedBox(height: 10),
            boldText(
                "Vendors, Consultants, and Other Third-Party Service Providers."),
            text(
              "We may share your data with third-party vendors, service providers, contractors, or agents (\"third parties\") who perform services for us or on our behalf and require access to such information to do that work. We have contracts in place with our third parties, which are designed to help safeguard your personal information. This means that they cannot do anything with your personal information unless we have instructed them to do it. They will also not share your personal information with any organization apart from us. They also commit to protecting the data they hold on our behalf and to retain it for the period we instruct.",
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

            bulletBoldTitle("Business Transfers",
                "We may share or transfer your information in connection with, or during negotiations of, any merger, sale of company assets, financing, or acquisition of all or a portion of our business to another company."),
            const SizedBox(height: 10),
            bulletBoldTitle("When we use Google Maps Platform APIs",
                "We may share your information with certain Google Maps Platform APIs (e.g., Google Maps API, Places API). Google Maps uses GPS, Wi-Fi, and cell towers to estimate your location. GPS is accurate to about 20 meters, while Wi-Fi and cell towers help improve accuracy when GPS signals are weak, like indoors. This data helps Google Maps provide directions, but it is not always perfectly precise. We obtain and store on your device (\"cache\") your location. You may revoke your consent anytime by contacting us at the contact details provided at the end of this document."),
            const SizedBox(height: 10),
            bulletBoldTitle("Other Users",
                "When you share personal information (for example, by posting comments, contributions, or other content to the Services) or otherwise interact with public areas of the Services, such personal information may be viewed by all users and may be publicly made available outside the Services in perpetuity. Similarly, other users will be able to view descriptions of your activity, communicate with you within our Services, and view your profile."),

            const SizedBox(height: 20),

            sectionTitle("4. DO WE USE COOKIES AND TRACKING TECHNOLOGIES?"),
            const SizedBox(height: 10),

            text(
                "We may use cookies and similar tracking technologies (like web beacons and pixels) to gather information when you interact with our Services. Some online tracking technologies help us maintain the security of our Services and your account, prevent crashes, fix bugs, save your preferences, and assist with basic site functions."),
            const SizedBox(height: 15),
            text(
                "We also permit third parties and service providers to use online tracking technologies on our Services for analytics and advertising, including to help manage and display advertisements, to tailor advertisements to your interests, or to send abandoned shopping cart reminders (depending on your communication preferences). The third parties and service providers use their technology to provide advertising about products and services tailored to your interests which may appear either on our Services or on other websites."),
            const SizedBox(height: 15),
            text(
                "Specific information about how we use such technologies and how you can refuse certain cookies is set out in our Cookie Notice."),

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
                "As part of our Services, we offer products, features, or tools powered by artificial intelligence, machine learning, or similar technologies (collectively, \"AI Products\"). These tools are designed to enhance your experience and provide you with innovative solutions. The terms in this Privacy Notice govern your use of the AI Products within our Services."),
            const SizedBox(height: 20),

            boldText("Use of AI Technologies"),
            const SizedBox(height: 5),
            text(
                "We provide the AI Products through third-party service providers (\"AI Service Providers\"), including Google Cloud AI. As outlined in this Privacy Notice, your input, output, and personal information will be shared with and processed by these AI Service Providers to enable your use of our AI Products for purposes outlined in [\"WHEN AND WITH WHOM DO WE SHARE YOUR PERSONAL INFORMATION?\"] You must not use the AI Products in any way that violates the terms or policies of any AI Service Provider."),
            const SizedBox(height: 20),

            sectionTitle("6. HOW LONG DO WE KEEP YOUR INFORMATION?"),
            const SizedBox(height: 10),
            text(
                "We will only keep your personal information for as long as it is necessary for the purposes set out in this Privacy Notice, unless a longer retention period is required or permitted by law (such as tax, accounting, or other legal requirements). No purpose in this notice will require us keeping your personal information for longer than three (3) months past the termination of the user's account."),

            text(
                "When we have no ongoing legitimate business need to process your personal information, we will either delete or anonymize such information, or, if this is not possible (for example, because your personal information has been stored in backup archives), then we will securely store your personal information and isolate it from any further processing until deletion is possible."),

            const SizedBox(height: 20),

            sectionTitle("7. WHAT ARE YOUR PRIVACY RIGHTS?"),
            const SizedBox(height: 10),
            boldText("Withdrawing your consent:"),
            text(
                "If we are relying on your consent to process your personal information, which may be express and/or implied consent depending on the applicable law, you have the right to withdraw your consent at any time. You can withdraw your consent at any time by contacting us by using the contact details provided in the section \"HOW CAN YOU CONTACT US ABOUT THIS NOTICE?\" below."),
            const SizedBox(height: 10),
            text(
                "However, please note that this will not affect the lawfulness of the processing before its withdrawal nor, when applicable law allows, will it affect the processing of your personal information conducted in reliance on lawful processing grounds other than consent."),

            const SizedBox(height: 10),

            sectionTitle("Account Information"),
            const SizedBox(height: 5),
            text(
                "If you would at any time like to review or change the information in your account or terminate your account, you can:"),
            const SizedBox(height: 10),
            bulletPoint("Contact us for data requests"),
            const SizedBox(height: 5),
            bulletPoint("Update account settings"),
            const SizedBox(height: 10),

            text(
                "Upon your request to terminate your account, we will deactivate or delete your account and information from our active databases. However, we may retain some information in our files to prevent fraud, troubleshoot problems, assist with any investigations, enforce our legal terms and/or comply with applicable legal requirements."),
            text(
                "If you have questions or comments about your privacy rights, you may email us at dpcompahinay@up.edu.ph."),
            const SizedBox(height: 20),

            sectionTitle("8. CONTROLS FOR DO-NOT-TRACK FEATURES"),
            const SizedBox(height: 10),
            text(
                "Most web browsers and some mobile operating systems and mobile applications include a Do-Not-Track (\"DNT\") feature or setting you can activate to signal your privacy preference not to have data about your online browsing activities monitored and collected. At this stage, no uniform technology standard for recognizing and implementing DNT signals has been finalized. As such, we do not currently respond to DNT browser signals or any other mechanism that automatically communicates your choice not to be tracked online. If a standard for online tracking is adopted that we must follow in the future, we will inform you about that practice in a revised version of this Privacy Notice."),
            const SizedBox(height: 20),

            sectionTitle(
                "9. HOW CAN YOU REVIEW, UPDATE, OR DELETE THE DATA WE COLLECT FROM YOU?"),
            const SizedBox(height: 10),
            text(
              "You have the right to request access, corrections, or deletion of your data. Contact us to submit a data subject access request.",
            ),
            const SizedBox(height: 20),

            sectionTitle("10. HOW CAN YOU CONTACT US ABOUT THIS NOTICE?"),
            const SizedBox(height: 10),
            text(
                "If you have any inquiries or feedback regarding this notice, you can reach us via email at dpcompahinay@up.edu.ph or call us at 09615121467."),
            const SizedBox(height: 20),
            text("University of the Philippines Los Baños"),
            text("Los Baños, Laguna"),
            text("Philippines"),
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
