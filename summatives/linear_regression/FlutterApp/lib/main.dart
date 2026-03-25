import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const CropApp());
}

class CropApp extends StatelessWidget {
  const CropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PredictorScreen(),
    );
  }
}

class PredictorScreen extends StatefulWidget {
  const PredictorScreen({super.key});

  @override
  State<PredictorScreen> createState() => _PredictorScreenState();
}

class _PredictorScreenState extends State<PredictorScreen> {
  final rainfallController = TextEditingController();
  final temperatureController = TextEditingController();
  final fertilizerController = TextEditingController();
  final irrigationController = TextEditingController();
  final daysController = TextEditingController();

  String? region;
  String? soil;
  String? crop;
  String? weather;

  String result = "";
  bool loading = false;

  final String url =
      "https://linear-regression-model-1901.onrender.com/predict";

  Future<void> predict() async {
    setState(() {
      loading = true;
      result = "";
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "rainfall": double.parse(rainfallController.text),
          "temperature": double.parse(temperatureController.text),
          "fertilizer_used": int.parse(fertilizerController.text),
          "irrigation_used": int.parse(irrigationController.text),
          "days_to_harvest": int.parse(daysController.text),
          "region": region ?? "West",
          "soil_type": soil ?? "Loamy",
          "crop": crop ?? "Maize",
          "weather_condition": weather ?? "Sunny",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          result = "Predicted Yield: ${data['predicted_yield']}";
        });
      } else {
        setState(() {
          result = "Server error occurred";
        });
      }
    } catch (e) {
      setState(() {
        result = "Connection error: $e";
      });
    }

    setState(() {
      loading = false;
    });
  }

  Widget inputField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.green.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget dropdownField(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.green.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      appBar: AppBar(
        title: const Text("Crop Yield Predictor"),
        backgroundColor: Colors.green.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  inputField(rainfallController, "Rainfall (mm)"),
                  inputField(temperatureController, "Temperature (°C)"),
                  inputField(fertilizerController, "Fertilizer Used (0/1)"),
                  inputField(irrigationController, "Irrigation Used (0/1)"),
                  inputField(daysController, "Days to Harvest"),

                  dropdownField(
                    "Region",
                    ["West", "East", "North", "South"],
                    region,
                    (val) => setState(() => region = val),
                  ),

                  dropdownField(
                    "Soil Type",
                    ["Loamy", "Sandy", "Clay"],
                    soil,
                    (val) => setState(() => soil = val),
                  ),

                  dropdownField(
                    "Crop",
                    ["Maize", "Rice", "Beans"],
                    crop,
                    (val) => setState(() => crop = val),
                  ),

                  dropdownField(
                    "Weather",
                    ["Sunny", "Rainy", "Cloudy"],
                    weather,
                    (val) => setState(() => weather = val),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.all(14),
                      ),
                      onPressed: loading ? null : predict,
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Predict Yield"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    result,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
