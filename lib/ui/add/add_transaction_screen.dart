// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/transaction_model.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/transaction_provider.dart';
//
// class AddTransactionScreen extends StatefulWidget {
//   const AddTransactionScreen({super.key});
//
//   @override
//   State<AddTransactionScreen> createState() => _AddTransactionScreenState();
// }
//
// class _AddTransactionScreenState extends State<AddTransactionScreen> {
//   final _name = TextEditingController();
//   final _amount = TextEditingController();
//   String _category = 'Food';
//   DateTime _date = DateTime.now();
//
//   @override
//   Widget build(BuildContext context) {
//     final uid = context.read<AuthProvider>().user!.uid;
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Transaction')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(controller: _name, decoration: const InputDecoration(labelText: 'Item Name')),
//             TextField(
//               controller: _amount,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(labelText: 'Amount'),
//             ),
//             DropdownButton<String>(
//               value: _category,
//               items: ['Food', 'Transport', 'Bills', 'Other']
//                   .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                   .toList(),
//               onChanged: (v) => setState(() => _category = v!),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 final tx = ExpenseTransaction(
//                   id: '',
//                   name: _name.text,
//                   amount: int.parse(_amount.text),
//                   category: _category,
//                   date: _date,
//                 );
//                 await context.read<TransactionProvider>().add(uid, tx);
//                 Navigator.pop(context);
//               },
//               child: const Text('Save'),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
