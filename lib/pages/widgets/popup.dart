// import 'package:flutter/material.dart';

// class PopUpWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) => AlertDialog(
//         title: Text('Edit stop name'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             TextField(
//               autofocus: true,
//               keyboardType: TextInputType.text,
//               controller: _popUpTextController,
//             )
//           ],
//         ),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: Text('Close'),
//           ),
//           TextButton(
//             onPressed: () {
//               _updateItem(
//                 _editingFavItem,
//                 _popUpTextController.text.trim(),
//               );
//               Navigator.of(context).pop();
//             },
//             child: Text('Save'),
//           ),
//         ],
//       );
// }
