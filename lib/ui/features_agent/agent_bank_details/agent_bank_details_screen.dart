// ignore_for_file: use_build_context_synchronously
import 'package:biztidy_agent_app/app/helpers/agent_sharedprefs.dart';
import 'package:biztidy_agent_app/app/services/agent_firebase_service.dart';
import 'package:biztidy_agent_app/main.dart' show logger;
import 'package:biztidy_agent_app/ui/features_agent/agent_auth/agent_auth_model/agent_model.dart';
import 'package:biztidy_agent_app/ui/shared/spacer.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AgentBankDetailsScreen extends StatefulWidget {
  const AgentBankDetailsScreen({super.key, this.existing});
  final BankDetails? existing;

  @override
  State<AgentBankDetailsScreen> createState() =>
      _AgentBankDetailsScreenState();
}

class _AgentBankDetailsScreenState extends State<AgentBankDetailsScreen> {
  final _accountNumberCtrl = TextEditingController();

  ({String name, String code})? _selectedBank;
  String? _verifiedAccountName;
  bool _nameMatches = false;       // true when verified name matches agent name
  bool _verifying = false;
  bool _saving = false;
  String _error = '';
  String? _agentRegisteredName;    // loaded from local storage on initState

  @override
  void initState() {
    super.initState();
    _loadAgentName();
    if (widget.existing != null) {
      _accountNumberCtrl.text = widget.existing!.accountNumber;
      _verifiedAccountName = widget.existing!.accountName;
      _nameMatches = true; // already verified and saved previously
      try {
        _selectedBank = nigerianBanks
            .firstWhere((b) => b.code == widget.existing!.bankCode);
      } catch (_) {}
    }
  }

  Future<void> _loadAgentName() async {
    final agent = await getLocallySavedAgentDetails();
    if (mounted) {
      setState(() => _agentRegisteredName = agent?.name);
    }
  }

  @override
  void dispose() {
    _accountNumberCtrl.dispose();
    super.dispose();
  }

  // ── Name matching logic ────────────────────────────────────────────────────
  /// Returns true if the verified account name shares at least 2 meaningful
  /// words with the agent's registered name, OR the registered name is fully
  /// contained in the verified name (banks often reorder name parts).
  bool _namesMatch(String registeredName, String verifiedName) {
    final reg = registeredName.toLowerCase().trim();
    final ver = verifiedName.toLowerCase().trim();

    // Exact substring match (handles "JOHN DOE" contained in "MR JOHN DOE")
    if (ver.contains(reg) || reg.contains(ver)) return true;

    // Word-overlap: count shared meaningful words (≥ 3 chars)
    final regWords =
        reg.split(RegExp(r'\s+')).where((w) => w.length >= 3).toSet();
    final verWords =
        ver.split(RegExp(r'\s+')).where((w) => w.length >= 3).toSet();

    final overlap = regWords.intersection(verWords).length;
    return overlap >= 2; // at least 2 name words must match
  }

  // ── Verify account via Paystack ────────────────────────────────────────────
  Future<void> _verify() async {
    final accNum = _accountNumberCtrl.text.trim();

    if (_selectedBank == null) {
      setState(() => _error = 'Please select your bank');
      return;
    }
    if (accNum.length != 10) {
      setState(() => _error = 'Account number must be exactly 10 digits');
      return;
    }

    setState(() {
      _verifying = true;
      _verifiedAccountName = null;
      _nameMatches = false;
      _error = '';
    });

    final paystackKey = await AgentFirebaseService().fetchPaystackKey();
    if (paystackKey == null) {
      setState(() {
        _verifying = false;
        _error = 'Could not reach the verification service. Check your '
            'internet connection and retry.';
      });
      return;
    }

    final name = await AgentFirebaseService().verifyBankAccount(
      accountNumber: accNum,
      bankCode: _selectedBank!.code,
      paystackSecretKey: paystackKey,
    );

    setState(() {
      _verifying = false;
      if (name == null) {
        // Account not found — give a specific, helpful message
        _error = 'Account not found at ${_selectedBank!.name}.\n\n'
            'Tips:\n'
            '• Make sure you selected the right bank\n'
            '• For OPay, PalmPay and Moniepoint use your 10-digit wallet number\n'
            '• Kuda account numbers are exactly 10 digits starting with 0';
        _verifiedAccountName = null;
      } else {
        _verifiedAccountName = name;
        // ── Security check: verified name must match agent's registered name
        if (_agentRegisteredName != null &&
            _agentRegisteredName!.trim().isNotEmpty) {
          _nameMatches = _namesMatch(_agentRegisteredName!, name);
          if (!_nameMatches) {
            _error = 'This account does not appear to belong to you.\n\n'
                'Verified name: $name\n'
                'Your registered name: $_agentRegisteredName\n\n'
                'BizTidy only allows withdrawals to your own account '
                'to protect all parties. Please use a bank account '
                'registered in your own name.';
          }
        } else {
          // No local name to compare — allow but log for admin review
          _nameMatches = true;
          logger.w('Could not check name match — no local agent name found');
        }
      }
    });
  }

  // ── Save to Firestore ──────────────────────────────────────────────────────
  Future<void> _save() async {
    if (_verifiedAccountName == null) {
      setState(() => _error = 'Please verify your account first');
      return;
    }
    if (!_nameMatches) {
      setState(
          () => _error = 'You can only save an account registered in your own name.');
      return;
    }

    final agent = await getLocallySavedAgentDetails();
    if (agent?.agentId == null) return;

    setState(() => _saving = true);

    // ── Step 1: Create Paystack Transfer Recipient ─────────────────────────
    // This registers the account with Paystack so future payouts can be
    // initiated instantly without re-entering account details.
    final paystackKey = await AgentFirebaseService().fetchPaystackKey();
    String? recipientCode;
    if (paystackKey != null) {
      recipientCode = await AgentFirebaseService().createPaystackRecipient(
        accountName: _verifiedAccountName!,
        accountNumber: _accountNumberCtrl.text.trim(),
        bankCode: _selectedBank!.code,
        paystackSecretKey: paystackKey,
      );
    }
    // If recipient creation fails we still save the bank details — the admin
    // can fall back to manual transfer. We just won't have a recipient_code.
    if (recipientCode == null) {
      // Non-blocking — inform the agent but still proceed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bank details saved, but automatic payouts are unavailable right now. '
            'Admin will process your withdrawal manually.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
    }

    // ── Step 2: Save to Firestore ──────────────────────────────────────────
    final bankDetails = BankDetails(
      bankName: _selectedBank!.name,
      bankCode: _selectedBank!.code,
      accountNumber: _accountNumberCtrl.text.trim(),
      accountName: _verifiedAccountName!,
      recipientCode: recipientCode,
    );

    final ok = await AgentFirebaseService().saveBankDetails(
      agentId: agent!.agentId!,
      bankDetails: bankDetails.toJson(),
    );

    if (ok) {
      final updated = agent.copyWith(bankDetails: bankDetails);
      await saveAgentDetailsLocally(updated);
      if (mounted) Navigator.pop(context, true);
    }

    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryThemeColor,
        foregroundColor: AppColors.plainWhite,
        elevation: 0,
        title: Text('Bank Details',
            style: AppStyles.keyStringStyle(18, AppColors.plainWhite)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Security info banner ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryThemeColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primaryThemeColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.security_outlined,
                      color: AppColors.primaryThemeColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'For your security, the account name must match your '
                      'registered BizTidy name. Payouts are only sent to '
                      'accounts that belong to you.',
                      style: AppStyles.subStringStyle(13, AppColors.darkGray),
                    ),
                  ),
                ],
              ),
            ),
            verticalSpacer(24),

            // ── Bank dropdown ────────────────────────────────────────────
            Text('Select Bank',
                style: AppStyles.regularStringStyle(13, AppColors.fullBlack)),
            verticalSpacer(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.lightGray.withValues(alpha: 0.6)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<({String name, String code})>(
                  value: _selectedBank,
                  isExpanded: true,
                  hint: Text('Choose your bank',
                      style: AppStyles.subStringStyle(14, AppColors.darkGray)),
                  items: nigerianBanks
                      .map((b) => DropdownMenuItem(
                            value: b,
                            child: Text(b.name,
                                style: AppStyles.subStringStyle(
                                    14, AppColors.fullBlack)),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() {
                    _selectedBank = val;
                    _verifiedAccountName = null;
                    _nameMatches = false;
                    _error = '';
                  }),
                ),
              ),
            ),
            verticalSpacer(20),

            // ── Account number ───────────────────────────────────────────
            Text('Account Number',
                style: AppStyles.regularStringStyle(13, AppColors.fullBlack)),
            verticalSpacer(8),
            TextField(
              controller: _accountNumberCtrl,
              keyboardType: TextInputType.number,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {
                _verifiedAccountName = null;
                _nameMatches = false;
                _error = '';
              }),
              decoration: InputDecoration(
                hintText: '10-digit account number',
                hintStyle: AppStyles.subStringStyle(14, AppColors.darkGray),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                counterText: '',
              ),
              style: AppStyles.regularStringStyle(15, AppColors.fullBlack),
            ),
            verticalSpacer(16),

            // ── Verify button ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _verifying ? null : _verify,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryThemeColor,
                  side: BorderSide(color: AppColors.primaryThemeColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _verifying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Verify Account'),
              ),
            ),
            verticalSpacer(16),

            // ── Verification result ──────────────────────────────────────
            if (_verifiedAccountName != null && _nameMatches)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.normalGreen.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.normalGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: AppColors.normalGreen, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Account Verified ✓',
                              style: AppStyles.regularStringStyle(
                                  13, AppColors.normalGreen)),
                          verticalSpacer(2),
                          Text(
                            _verifiedAccountName!,
                            style: AppStyles.keyStringStyle(
                                16, AppColors.fullBlack),
                          ),
                          verticalSpacer(2),
                          Text(
                            'Name matches your BizTidy profile',
                            style: AppStyles.subStringStyle(
                                12, AppColors.normalGreen),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // ── Error / mismatch message ─────────────────────────────────
            if (_error.isNotEmpty) ...[
              verticalSpacer(4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.coolRed.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.coolRed.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline,
                        color: AppColors.coolRed, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error,
                        style: AppStyles.subStringStyle(
                            13, AppColors.coolRed),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            verticalSpacer(28),

            // ── Save button — disabled until name verified and matches ────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_saving || !_nameMatches || _verifiedAccountName == null)
                    ? null
                    : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryThemeColor,
                  foregroundColor: AppColors.plainWhite,
                  disabledBackgroundColor:
                      AppColors.primaryThemeColor.withValues(alpha: 0.35),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save Bank Details'),
              ),
            ),
            verticalSpacer(40),
          ],
        ),
      ),
    );
  }
}
