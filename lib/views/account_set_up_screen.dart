

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountSetupScreen extends StatefulWidget {
  const AccountSetupScreen({Key? key}) : super(key: key);

  @override
  State<AccountSetupScreen> createState() => _AccountSetupScreenState();
}

class _AccountSetupScreenState extends State<AccountSetupScreen> {
  // State variables for loading animations
  bool _isConnectingBank = false;
  bool _isSavingManual = false;

  // Controllers for manual entry
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _routingController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    _routingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Fintech light background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            // Handle back navigation
          },
        ),
        title: const Text(
          'Account Setup',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              const Text(
                'Link Your Bank',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect your primary account to automatically verify income, track loan eligibility, and enable fast EMI payments.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // --- Instant Connect Card (Plaid/Open Banking style) ---
              _buildInstantConnectCard(),

              const SizedBox(height: 32),

              // --- Divider ---
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'OR ENTER MANUALLY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),

              const SizedBox(height: 32),

              // --- Manual Entry Form ---
              _buildSectionLabel('Account Holder Name'),
              _buildTextField(
                controller: _nameController,
                hintText: 'e.g. Alex Harrison',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              _buildSectionLabel('Account Number'),
              _buildTextField(
                controller: _accountController,
                hintText: '0000 0000 0000',
                icon: Icons.numbers,
                isNumber: true,
              ),
              const SizedBox(height: 20),

              _buildSectionLabel('Routing / IFSC Code'),
              _buildTextField(
                controller: _routingController,
                hintText: 'e.g. AB123456789',
                icon: Icons.account_balance_outlined,
              ),
              const SizedBox(height: 40),

              // --- Submit Button ---
              _buildSubmitButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildInstantConnectCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)), // Light border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBankLogo(Icons.account_balance, Colors.blue.shade700),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 40,
                height: 2,
                color: Colors.grey.shade300,
              ),
              _buildBankLogo(Icons.sync_alt, Colors.green.shade600),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 40,
                height: 2,
                color: Colors.grey.shade300,
              ),
              _buildBankLogo(Icons.verified_user, const Color(0xFF1D4ED8)),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Instant & Secure Connection',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Uses 256-bit encryption. We never see or store your bank login credentials.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isConnectingBank
                ? null
                : () async {
              setState(() => _isConnectingBank = true);
              // Simulate opening a bank connection modal (like Plaid)
              await Future.delayed(const Duration(seconds: 2));
              if (mounted) {
                setState(() => _isConnectingBank = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bank connected successfully!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D4ED8), // Fintech Blue
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isConnectingBank
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text(
              'Connect Securely',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankLogo(IconData icon, Color color) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSavingManual
          ? null
          : () async {
        setState(() => _isSavingManual = true);
        // Simulate API call to save details
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() => _isSavingManual = false);

          context.go("/login");
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D4ED8),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF1D4ED8), width: 1.5),
        ),
        elevation: 0,
      ),
      child: _isSavingManual
          ? const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          color: Color(0xFF1D4ED8),
          strokeWidth: 2,
        ),
      )
          : const Text(
        'Save Manual Details',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}