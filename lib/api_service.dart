import 'dart:convert'; // For decoding JSON data
import 'package:http/http.dart' as http; // For making HTTP requests

class ApiService {
  // --- Configuration ---

  // IMPORTANT: Replace 'YOUR_API_KEY' with your actual free API key from currencyapi.com
  // In a real production app, avoid hardcoding keys directly like this.
  // Consider using environment variables or a configuration file.
  final String _apiKey = 'cur_live_lhR87XpmLGBcQUybGVshFKyNTBvUybsOt9dSMPC5';

  // Base URL for the currencyapi.com v3 API
  final String _baseUrl = 'https://api.currencyapi.com/v3/';
  // --- Methods ---

  /// Fetches the latest exchange rates relative to a base currency.
  ///
  /// For the free tier on currencyapi.com, you might be restricted
  /// to using their default base currency (often USD). Check their docs.
  /// The API returns data like: {"data": {"EUR": {"code": "EUR", "value": 0.95}, ...}}
  Future<Map<String, dynamic>> getLatestRates({String baseCurrency = 'USD'}) async {
    // Construct the API endpoint URL
    // Note: Free plan might ignore or disallow the base_currency parameter if it's not USD.
    final url = Uri.parse('${_baseUrl}latest?apikey=$_apiKey&base_currency=$baseCurrency');
    print('Requesting rates from: $url'); // For debugging

    try {
      // Send GET request
      final response = await http.get(url);

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Decode the JSON response body
        final data = jsonDecode(response.body);

        // Check if the expected 'data' field exists and is not null
        if (data != null && data['data'] is Map<String, dynamic>) {
          // Return the map of currency rates
          return data['data'];
        } else {
          // Throw an exception if the data format is unexpected
          print('API Error: Invalid data format received. Response: ${response.body}');
          throw Exception('Invalid data format received from API');
        }
      } else {
        // Handle API errors (e.g., invalid key, rate limits, server errors)
        print('API Error: Failed to load rates. Status Code: ${response.statusCode}. Response: ${response.body}');
        throw Exception('Failed to load rates: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors or other exceptions during the request
      print("Network/Fetch Error: $e");
      throw Exception('Failed to connect to the currency API. Check network connection.');
    }
  }

  /// Fetches the list of all available/supported currencies.
  ///
  /// The API returns data like: {"data": {"AED": {"symbol": "...", "name": "...", ...}, ...}}
  Future<Map<String, dynamic>> getCurrencies() async {
    // Construct the API endpoint URL for currencies
    final url = Uri.parse('${_baseUrl}currencies?apikey=$_apiKey');
    print('Requesting currencies from: $url'); // For debugging

    try {
      // Send GET request
      final response = await http.get(url);

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response
        final data = jsonDecode(response.body);

        // Check if the expected 'data' field exists and is not null
        if (data != null && data['data'] is Map<String, dynamic>) {
          // Return the map of currency details
          return data['data'];
        } else {
          // Throw an exception if the data format is unexpected
          print('API Error: Invalid currency data format received. Response: ${response.body}');
          throw Exception('Invalid currency data format received');
        }
      } else {
        // Handle API errors
        print('API Error: Failed to load currencies. Status Code: ${response.statusCode}. Response: ${response.body}');
        throw Exception('Failed to load currencies: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors or other exceptions
      print("Network/Fetch Error: $e");
      throw Exception('Failed to connect to the currency API. Check network connection.');
    }
  }
}