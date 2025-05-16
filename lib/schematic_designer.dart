import 'package:energize/battery_bank_sizing.dart';
import 'package:energize/energy_demand.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'dart:convert';
import 'package:energize/location.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SchematicDesigner extends StatefulWidget {
  const SchematicDesigner({super.key});

  @override
  State<SchematicDesigner> createState() => _SchematicDesignerState();
}

class _SchematicDesignerState extends State<SchematicDesigner> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? schematicImage;
  String? errorMessage;

  // Pre-filled design parameters with sample values
  final designParams = {
    'typeOfPanel': 'Monocrystalline',
    'pHSvalue': '$pHSvalue',
    'totalPower': '$totalEnergyConsumed',
    'EnergyinverterEfficiency': '$inverterEfficiency',
    'depthOfDischarge': '$depthOfDischarge',
    'energyDemand': '$energyDemand',
    'batteryEnergyCapacity': '$batteryEnergyCapacity',
    'batteryCapacity': '$batteryCapacity',
    'performanceRatioPanel': '$performanceRatioPanel',
    'solarEnergyDemand': '$solarEnergyDemand',
    'sizeOfSolarPanelArray': '$sizeOfSolarPanelArray',
    'capacityOfEachPanel': '$capacityOfEachPanel',
    'numberOfSolarPanels': '$numberOfSolarPanels',
    'maximumPowerVoltageOfArray': '$maximumPowerVoltageOfArray',
    'sizeOfChargeControllers': '$sizeOfChargeControllers',
  };

  // Controllers for text fields
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    designParams.forEach((key, value) {
      controllers[key] = TextEditingController(text: value);
    });
  }

  @override
  void dispose() {
    controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) =>
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('Solar PV System Design Parameters'),
                ),
                pw.SizedBox(height: 20),
                ...designParams.entries.map((entry) =>
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 10),
                      child: pw.Text(
                        '${_formatLabel(entry.key)}: ${entry.value}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    )).toList(),
              ],
            ),
      ),
    );

    // Get directory for saving file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/solar_design_parameters.pdf';

    // Save PDF
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Success'),
            content: Text('PDF saved to: $filePath'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> generateSchematic() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final projectId = dotenv.env['GCP_PROJECT_ID'];
      final location = 'us-central1';
      final apiEndpoint = 'https://$location-aiplatform.googleapis.com/v1/projects/$projectId/locations/$location/publishers/google/models/imagegeneration@002:predict';

      final prompt = '''A blueprint schematic image of a solar installation of a house with the following requirements:
      
      - Solar Panel Array (${designParams['typeOfPanel']})
        * Array Size: ${designParams['sizeOfSolarPanelArray']}
        * Number of Panels: ${designParams['numberOfSolarPanels']}
        * Panel Capacity: ${designParams['capacityOfEachPanel']}
      - Battery Bank (${designParams['batteryCapacity']})
      - Charge Controller (${designParams['sizeOfChargeControllers']})
      - Inverter (${designParams['EnergyinverterEfficiency']})
      
      Show all electrical connections between components using proper schematic notation. 
      Include neccessary fuses, circuit breakers, and protection apparatus ''';


      final accessToken = await _getAccessToken();

      final requestBody = {
        "instances": [{
          "prompt": prompt
        }],
        "parameters": {
          "sampleCount": 1
        }
      };

      print('Sending request to Vertex AI');
      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final predictions = data['predictions'] as List;

        if (predictions.isEmpty) throw Exception('No predictions returned');

        // Updated to handle new response format
        final imageData = predictions[0]['image'];
        if (imageData == null) throw Exception('No image data in prediction');

        final bytes = base64Decode(imageData);
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/schematic.png');
        await tempFile.writeAsBytes(bytes);

        setState(() {
          schematicImage = tempFile.path;
          isLoading = false;
        });

        _showSchematic();
      } else {
        throw Exception('API request failed: ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // Updated authentication method using googleapis_auth
  Future<String> _getAccessToken() async {
    final client = http.Client();
    try {
      // Load the service account credentials from your JSON file
      final serviceAccountCredentials = ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": dotenv.env['GCP_PROJECT_ID'],
        "private_key_id": dotenv.env['GCP_PRIVATE_KEY_ID'],
        "private_key": dotenv.env['GCP_PRIVATE_KEY']?.replaceAll(r'\n', '\n'),
        "client_email": dotenv.env['GCP_CLIENT_EMAIL'],
        "client_id": dotenv.env['GCP_CLIENT_ID'],
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": dotenv.env['GCP_CLIENT_CERT_URL'],
      });

      // Get access credentials with the client instance
      final accessCredentials = await obtainAccessCredentialsViaServiceAccount(
        serviceAccountCredentials,
        ['https://www.googleapis.com/auth/cloud-platform'],
        client,
      );

      return accessCredentials.accessToken.data;
    } finally {
      client.close(); // Make sure to close the client when done
    }
  }

  void _showDesignParameters() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Design Parameters'),
            content: SizedBox(
              width: double.maxFinite,
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.8,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...designParams.keys.map((key) =>
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: TextFormField(
                              controller: controllers[key],
                              decoration: InputDecoration(
                                labelText: _formatLabel(key),
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: _getKeyboardType(key),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter ${_formatLabel(key)}';
                                }
                                return null;
                              },
                            ),
                          )).toList(),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: generatePDF,
                        child: const Text('Export to PDF'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Update designParams with current values
                    controllers.forEach((key, controller) {
                      designParams[key] = controller.text;
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  String _formatLabel(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .split(' ')
        .map((word) =>
    word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');
  }

  TextInputType _getKeyboardType(String key) {
    if (key.toLowerCase().contains('number') ||
        key.toLowerCase().contains('quantity') ||
        key.toLowerCase().contains('capacity') ||
        key.toLowerCase().contains('power') ||
        key.toLowerCase().contains('voltage') ||
        key.toLowerCase().contains('size')) {
      return TextInputType.number;
    }
    return TextInputType.text;
  }

  void _showSchematic() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Schematic'),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.8,
          child: schematicImage != null
              ? SingleChildScrollView(
            child: Column(
              children: [
                Image.file(File(schematicImage!)),
                const SizedBox(height: 20),
                // Optionally show text description below the image
                Text(
                  'Schematic diagram showing $numberOfSolarPanels ${designParams['typeOfPanel']} panels '
                      'connected to a ${designParams['batteryCapacity']} battery bank via '
                      'charge controllers and inverter.',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          )
              : const Center(
            child: Text('No schematic generated yet'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solar PV System Designer'),
      ),
      body: Stack( // Changed to Stack for overlay loading
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isLoading ? null : _showDesignParameters,
                  child: const Text('Design Parameters'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : generateSchematic,
                  child: const Text('Draw Schematic'),
                ),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Generating schematic...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}