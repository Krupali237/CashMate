// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
//
// class AboutUs extends StatefulWidget {
//   const AboutUs({super.key});
//
//   @override
//   State<AboutUs> createState() => _AboutUsState();
// }
//
// class _AboutUsState extends State<AboutUs> {
//   File? _selectedImage;
//
//   Future<void> _pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//
//     if (image != null) {
//       setState(() {
//         _selectedImage = File(image.path);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text('About Us', style: TextStyle(color: Colors.white)),
//         backgroundColor: const Color(0xC833A0B2),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: GestureDetector(
//                   onTap: _pickImage, // 🔹 Tap avatar to pick new image
//                   child: Column(
//                     children: [
//                       CircleAvatar(
//                         radius: 60,
//                         backgroundImage: _selectedImage != null
//                             ? FileImage(_selectedImage!)
//                             : const NetworkImage(
//                           "https://tse1.mm.bing.net/th?id=OIP.OhEeKrALIUwjGdb53m-vtQAAAA&pid=Api&P=0&h=180",
//                         ) as ImageProvider,
//                         child: Align(
//                           alignment: Alignment.bottomRight,
//                           child: CircleAvatar(
//                             radius: 18,
//                             backgroundColor: Colors.white,
//                             child: const Icon(Icons.camera_alt,
//                                 size: 20, color: Colors.black87),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Krupali',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.cyan.shade700,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//
//               /// 🔹 Team Info Card
//               Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Meet Our Team',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.cyan.shade700,
//                         ),
//                       ),
//                       Divider(color: Colors.cyan.shade700),
//                       buildInfoRow('Developed by:', 'MANDALI KRUPALI (23031701031)'),
//                       buildInfoRow('Mentored by:',
//                           'Prof. Mehul Bhundiya (Computer Engineering Department), School of Computer Science'),
//                       buildInfoRow('Explored by:',
//                           'ASWDC, School of Computer Science, School of Computer Science'),
//                       buildInfoRow('Eulogized by:',
//                           'Darshan University, Rajkot, Gujarat - INDIA'),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//
//               /// 🔹 About ASWDC
//               Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: const [
//                       Text(
//                         'About ASWDC',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.cyan,
//                         ),
//                       ),
//                       Divider(color: Colors.cyan),
//                       Text(
//                         'ASWDC is Application, Software and Website Development Center @ Darshan University run by '
//                             'Students and Staff of School of Computer Science.\n\n'
//                             'Sole purpose of ASWDC is to bridge the gap between university curriculum & industry demands. '
//                             'Students learn cutting-edge technology and skills. The sole purpose of ASWDC is to bridge the gap '
//                             'between university curriculum and industry demands. Students learn cutting-edge technologies, '
//                             'develop real-world applications, and experience a professional environment at ASWDC under the '
//                             'guidance of industry experts and faculty members.',
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//
//               /// 🔹 Contact Us
//               buildContactCard(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildInfoRow(String title, String content) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '$title ',
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           Expanded(
//             child: Text(
//               content,
//               style: const TextStyle(fontSize: 16),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// Widget buildContactCard() {
//   return Card(
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(8.0),
//     ),
//     elevation: 4,
//     child: Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SectionTitle(title: "Contact Us"),
//           const SizedBox(height: 8),
//           contactRow(Icons.email, "aswdc@darshan.ac.in"),
//           contactRow(Icons.phone, "+91-9727747317"),
//           contactRow(Icons.language, "www.darshan.ac.in"),
//           const SizedBox(height: 16),
//           const Divider(),
//           actionRow(Icons.share, "Share App"),
//           actionRow(Icons.apps, "More Apps"),
//           actionRow(Icons.star, "Rate Us"),
//           actionRow(Icons.thumb_up, "Like us on Facebook"),
//           actionRow(Icons.update, "Check For Update"),
//         ],
//       ),
//     ),
//   );
// }
//
// Widget contactRow(IconData icon, String text) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 4.0),
//     child: Row(
//       children: [
//         Icon(icon, color: Colors.cyan.shade700),
//         const SizedBox(width: 8),
//         Text(
//           text,
//           style: const TextStyle(fontSize: 14),
//         ),
//       ],
//     ),
//   );
// }
//
// Widget actionRow(IconData icon, String text) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 4.0),
//     child: Row(
//       children: [
//         Icon(icon, color: Colors.cyan.shade700),
//         const SizedBox(width: 8),
//         Text(
//           text,
//           style: const TextStyle(fontSize: 14),
//         ),
//       ],
//     ),
//   );
// }
//
// class SectionTitle extends StatelessWidget {
//   final String title;
//   const SectionTitle({Key? key, required this.title}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       title,
//       style: const TextStyle(
//         fontSize: 18,
//         fontWeight: FontWeight.bold,
//         color: Colors.cyan,
//       ),
//     );
//   }
// }


import 'package:aswdc_flutter_pub/aswdc_flutter_pub.dart';
import 'package:flutter/material.dart';


class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return
       SafeArea(
        child: Scaffold(
          body: DeveloperScreen(
            
            developerName: ' Krupali Mandali',
            mentorName: 'Prof. Mehul Bhundiya',
            exploredByName: 'ASWDC',
            isAdmissionApp: true,
            isDBUpdate: true,
            shareMessage: '',
            appTitle: 'Cashmate',
            appLogo: 'assets/icon/app_icon.png',
          ),
        ),


      /* SplashScreen(
        appLogo: APP_LOGO,
        appName: 'Quiz',
        appVersion: '1.9',
      ),*/
      // DeveloperScreen(
      //             developerName: 'Mehul Bhundiya',
      //             mentorName: 'Prof. Mehul Bhundiya',
      //             exploredByName: 'ASWDC',
      //             isAdmissionApp: false,
      //             shareMessage: '',
      //             appTitle: 'Example',
      //             appLogo: 'assets/icons/ic_launcher.png',
      //           )

    );

  }
}
