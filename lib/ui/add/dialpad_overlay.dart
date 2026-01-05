import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';

class DialPadOverlay extends StatefulWidget {
  const DialPadOverlay({super.key});

  @override
  State<DialPadOverlay> createState() => _DialPadOverlayState();
}

class _DialPadOverlayState extends State<DialPadOverlay> {
  String amountText = '';
  String category = 'Food';

  final List<String> categories = [
    'Food',
    'Transport',
    'Bills',
    'Shopping',
    'Health',
    'Other',
  ];

  void onKeyTap(String value) {
    setState(() => amountText += value);
  }

  void onBackspace() {
    if (amountText.isNotEmpty) {
      setState(() {
        amountText = amountText.substring(0, amountText.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user!.uid;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth >= 700;

        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWeb ? 420 : double.infinity,
                maxHeight: isWeb ? 720 : double.infinity,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.95),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(isWeb ? 20 : 24),
                    bottom: Radius.circular(isWeb ? 20 : 0),
                  ),
                ),
                child: Column(
                  children: [
                    /// Drag Handle (mobile only)
                    if (!isWeb)
                      Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                    /// Amount
                    Text(
                      amountText.isEmpty ? 'Rp 0' : 'Rp $amountText',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Category Chips
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: categories.map((c) {
                        final selected = category == c;

                        return ChoiceChip(
                          label: Text(c),
                          selected: selected,
                          onSelected: (_) {
                            setState(() => category = c);
                          },
                          selectedColor: Colors.teal,
                          backgroundColor: Colors.black.withOpacity(0.4),
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: selected
                                  ? Colors.teal
                                  : Colors.white38,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    /// Dial Pad
                    Expanded(child: _buildDialPad()),

                    /// Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: amountText.isEmpty
                            ? null
                            : () async {
                          final tx = ExpenseTransaction(
                            id: '',
                            name: category,
                            amount: int.parse(amountText),
                            category: category,
                            date: DateTime.now(),
                          );

                          await context
                              .read<TransactionProvider>()
                              .add(uid, tx);

                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// -------------------- DIAL PAD --------------------

  Widget _buildDialPad() {
    final keys = [
      '1','2','3',
      '4','5','6',
      '7','8','9',
      '', '0', 'back',
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final key = keys[index];

        if (key.isEmpty) return const SizedBox.shrink();

        if (key == 'back') {
          return _dialButton(
            icon: Icons.backspace,
            onTap: onBackspace,
          );
        }

        return _dialButton(
          label: key,
          onTap: () => onKeyTap(key),
        );
      },
    );
  }

  Widget _dialButton({
    String? label,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: label != null
              ? Text(
            label,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )
              : Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
