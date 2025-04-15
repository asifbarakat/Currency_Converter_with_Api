import 'package:flutter/material.dart';
import 'dart:async';
import 'api_service.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // --- State Variables ---
  final ApiService _apiService = ApiService();
  final TextEditingController _amountController = TextEditingController();

  Map<String, dynamic> _rates = {};
  Map<String, dynamic> _currencies = {};
  String? _fromCurrency = 'BDT'; // Default Changed
  String? _toCurrency = 'USD'; // Default Changed
  String _convertedAmount = '';
  bool _isLoading = true;
  String? _errorMessage;
  // REMOVED: int _selectedIndex = 0; // No longer needed

  // --- Lifecycle Methods (initState, dispose - remain the same) ---
  @override
  void initState() {
    super.initState();
    _loadData();
    _amountController.addListener(_convertCurrency);
  }

  @override
  void dispose() {
    _amountController.removeListener(_convertCurrency);
    _amountController.dispose();
    super.dispose();
  }

  // --- Data Fetching Logic (_loadData - remains the same) ---
  Future<void> _loadData() async {
     setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _currencies = await _apiService.getCurrencies();
      _rates = await _apiService.getLatestRates(baseCurrency: 'USD');

      if (_currencies.isNotEmpty) {
        if (!_currencies.containsKey(_fromCurrency)) {
          _fromCurrency = _currencies.keys.first;
        }
        if (!_currencies.containsKey(_toCurrency) || _toCurrency == _fromCurrency) {
           _toCurrency = _currencies.keys.firstWhere((k) => k == 'USD' && k != _fromCurrency,
              orElse: () => _currencies.keys.firstWhere((k) => k != _fromCurrency,
                  orElse: () => _currencies.keys.skip(1).first));
        }
      }
      setState(() { _isLoading = false; });
      _convertCurrency();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        print("Error loading data: $e");
      });
    }
  }


  // --- Conversion & Swap Logic (_convertCurrency, _swapCurrencies - remain the same) ---
 void _convertCurrency() {
    final String amountText = _amountController.text;
    if (amountText.isEmpty || _rates.isEmpty || _fromCurrency == null || _toCurrency == null) {
      setState(() { _convertedAmount = ''; });
      return;
    }
    final double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() { _convertedAmount = ''; });
      return;
    }

    double rateFromUSD = _rates[_fromCurrency!]?['value']?.toDouble() ?? 0.0;
    double rateToUSD = _rates[_toCurrency!]?['value']?.toDouble() ?? 0.0;

    if (_fromCurrency == 'USD') rateFromUSD = 1.0;
    if (_toCurrency == 'USD') rateToUSD = 1.0;

    if (rateFromUSD > 0 && rateToUSD > 0) {
      double amountInUSD = amount / rateFromUSD;
      double result = amountInUSD * rateToUSD;
      setState(() { _convertedAmount = result.toStringAsFixed(2); });
    } else {
      setState(() { _convertedAmount = 'Error'; });
      print("Error: Could not find rates relative to USD for $_fromCurrency or $_toCurrency");
    }
  }

  void _swapCurrencies() {
    if (_fromCurrency == _toCurrency || _fromCurrency == null || _toCurrency == null) return;
    setState(() {
      final String? temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _convertCurrency();
    });
  }

  // REMOVED: Method _onItemTapped is no longer needed
  // void _onItemTapped(int index) { ... }

  // --- UI Building ---
  @override
  Widget build(BuildContext context) {
    // Define colors (same as before)
    final Color backgroundColor = Colors.grey[200]!;
    final Color cardColor = Colors.white;
    final Color primaryTextColor = Colors.black87;
    final Color secondaryTextColor = Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        // --- LOGO ADDED HERE ---
        leading: Padding(
          padding: const EdgeInsets.all(8.0), // Add padding around the logo
          child: Image.asset(
            'assets/icons/logo.png', // Your logo path
             fit: BoxFit.cover,
            height: 40, // Adjust height as needed
            width: 40, // Adjust width as needed
          ),
        ),
        // --- END LOGO ADDITION ---

        title: Text('Currency Converter', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey[700],
        elevation: 6.0,
        shadowColor: Colors.black54,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: _isLoading
            ? Center( child: Padding( padding: const EdgeInsets.all(50.0), child: CircularProgressIndicator(color: Colors.blueGrey[700]), ))
            : _errorMessage != null
                ? Card(
                    color: Colors.red[50],
                    margin: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Error: $_errorMessage\nPlease check API key/network.',
                        style: TextStyle(color: Colors.red[900], fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _buildConverterUICards(cardColor, primaryTextColor, secondaryTextColor),
      ),

      // --- BOTTOM NAVIGATION BAR REMOVED ---
      // bottomNavigationBar: BottomNavigationBar(...)

    );
  }

  // --- Helper to build the main converter UI using Cards ---
  Widget _buildConverterUICards(Color cardColor, Color primaryTextColor, Color secondaryTextColor) {
    // Define card properties (same as before)
    const double cardElevation = 4.0;
    final cardShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0));
    const cardMargin = EdgeInsets.symmetric(vertical: 8.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Amount Input Card --- (Same as before)
        Card(
          elevation: cardElevation,
          shape: cardShape,
          margin: cardMargin,
          color: cardColor,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryTextColor),
              decoration: InputDecoration(
                labelText: 'Amount to Convert',
                labelStyle: TextStyle(color: secondaryTextColor),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.attach_money, color: secondaryTextColor, size: 24),
              ),
            ),
          ),
        ),

        // --- "FROM" Currency Card --- (Same as before)
        _buildCurrencySelectionCard(
          label: 'From',
          selectedCurrency: _fromCurrency,
          isFromBox: true,
          cardColor: cardColor,
          primaryTextColor: primaryTextColor,
          secondaryTextColor: secondaryTextColor,
          cardElevation: cardElevation,
          cardShape: cardShape,
          cardMargin: cardMargin,
        ),

        // --- Swap Button (Styled) --- (Same as before)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Center(
            child: IconButton(
              icon: Icon(Icons.swap_vert, size: 36, color: Colors.blueGrey[600]),
              onPressed: _swapCurrencies,
              tooltip: 'Swap Currencies',
               style: IconButton.styleFrom(
                 backgroundColor: Colors.grey[300],
                 shape: const CircleBorder(),
                 padding: const EdgeInsets.all(10),
                 elevation: 2.0,
               ),
            ),
          ),
        ),

        // --- "TO" Currency Card --- (Same as before)
        _buildCurrencySelectionCard(
          label: 'To',
          selectedCurrency: _toCurrency,
          isFromBox: false,
          cardColor: cardColor,
          primaryTextColor: primaryTextColor,
          secondaryTextColor: secondaryTextColor,
          cardElevation: cardElevation,
          cardShape: cardShape,
          cardMargin: cardMargin,
        ),
        const SizedBox(height: 16),

        // --- Converted Amount Card --- (Same as before)
        Card(
          elevation: cardElevation + 2,
          shape: cardShape,
          margin: cardMargin,
          color: Colors.blueGrey[700],
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Converted Amount:',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  _convertedAmount.isEmpty ? '---' : _convertedAmount,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (_convertedAmount.isNotEmpty && _toCurrency != null && _currencies[_toCurrency] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      _currencies[_toCurrency]?['name'] ?? _toCurrency!,
                      style: const TextStyle(fontSize: 14, color: Colors.white60),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // --- Helper Widget for Currency Selection Card --- (Same as before)
  Widget _buildCurrencySelectionCard({
    required String label,
    required String? selectedCurrency,
    required bool isFromBox,
    required Color cardColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required double cardElevation,
    required ShapeBorder cardShape,
    required EdgeInsets cardMargin,
  }) {
     // ... (implementation is the same as the previous version) ...
        return Card(
      elevation: cardElevation,
      shape: cardShape,
      margin: cardMargin,
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle( color: secondaryTextColor, fontSize: 14, ),
            ),
            DropdownButton<String>(
              value: selectedCurrency,
              isExpanded: true,
              underline: Container( height: 0, color: Colors.transparent, ),
              style: TextStyle(color: primaryTextColor, fontSize: 16),
              iconEnabledColor: secondaryTextColor,
              dropdownColor: cardColor,
              items: _currencies.keys.map((String key) {
                final currencyData = _currencies[key] as Map<String, dynamic>? ?? {};
                final symbol = currencyData['symbol_native'] ?? currencyData['symbol'] ?? '';
                final name = currencyData['name'] ?? key;
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(
                    '$symbol $key - $name',
                    overflow: TextOverflow.ellipsis,
                     style: TextStyle(color: primaryTextColor),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                 if (newValue == null) return;
                 setState(() {
                  String? otherCurrency = isFromBox ? _toCurrency : _fromCurrency;
                  if (newValue == otherCurrency) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text("Cannot select the same currency."),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.orange[700],
                    ));
                  } else {
                    if (isFromBox) { _fromCurrency = newValue; }
                    else { _toCurrency = newValue; }
                    _convertCurrency();
                  }
                 });
              },
              hint: Text('Select Currency', style: TextStyle(color: secondaryTextColor)),
            ),
          ],
        ),
      ),
    );
  }
}