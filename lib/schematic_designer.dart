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
    'sizeOfChargeControllers': '$sizeOfChargeControllers',};

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
      final prompt = '''A blueprint schematic image of a solar installation of a house with the following requirements:

- Solar Panel Array (${designParams['typeOfPanel']})
  * Array Size: ${designParams['sizeOfSolarPanelArray']}
  * Number of Panels: ${designParams['numberOfSolarPanels']}
  * Panel Capacity: ${designParams['capacityOfEachPanel']}
- Battery Bank (${designParams['batteryCapacity']})
- Charge Controller (${designParams['sizeOfChargeControllers']})
- Inverter (${designParams['EnergyinverterEfficiency']})

Show all electrical connections between components using proper schematic notation. 
Include necessary fuses, circuit breakers, and protection apparatus.''';

      final uri = Uri.parse('https://api.stability.ai/v2beta/stable-image/generate/ultra');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer ${dotenv.env['STABILITY_API_KEY']}'
        ..fields['prompt'] = prompt
        ..fields['output_format'] = 'png'
        ..fields['mode'] = 'text-to-image'
        ..fields['cfg_scale'] = '7'
        ..fields['steps'] = '30'
        ..fields['height'] = '512'
        ..fields['width'] = '512';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/schematic.png');
        await tempFile.writeAsBytes(bytes);


        setState(() {
          schematicImage = tempFile.path;
          isLoading = false;
        });

        _showSchematic();
      } else {
        throw Exception('❌ Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "❌ Request failed: $e";
      });
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