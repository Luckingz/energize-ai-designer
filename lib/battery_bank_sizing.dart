import 'package:energize/schematic_designer.dart';
import 'package:flutter/material.dart';
import 'energy_demand.dart';
import 'package:energize/location.dart';
import 'package:hive/hive.dart';

int? systemVoltage;
bool recommendedVoltageSelected = false;
bool radioButtonsEnabled = true;

const double inverterEfficiency = 0.9;  // Inverter Efficiency
const double depthOfDischarge = 0.3;    // Depth of Discharge of the Battery @ 30%
final double energyDemand = totalEnergyConsumed / inverterEfficiency; //Energy demand
final double batteryEnergyCapacity = energyDemand / depthOfDischarge;  // Battery Energy Capacity
final double batteryCapacity = batteryEnergyCapacity / (systemVoltage?.toDouble() ?? 0.0);
const double performanceRatioPanel = 0.65; // Performance Ratio of the Solar Panel
final double solarEnergyDemand = energyDemand / performanceRatioPanel; // Solar Panel Energy Demand
final double sizeOfSolarPanelArray = solarEnergyDemand / pHSvalue!; // Size of the Panel Array
const double capacityOfEachPanel = 200;
final double numberOfSolarPanels = sizeOfSolarPanelArray / capacityOfEachPanel; // Number of Solar Panels
const double maximumPowerVoltageOfArray = 70;
final double sizeOfChargeControllers = (sizeOfSolarPanelArray / maximumPowerVoltageOfArray) * 1.2;




class BatterySize extends StatefulWidget {
  const BatterySize({Key? key}) : super(key: key);

  @override
  State<BatterySize> createState() => _BatterySizeState();
}

class _BatterySizeState extends State<BatterySize> {

  void selectRecommendedVoltage() {
    setState(() {
      recommendedVoltageSelected = true;
      radioButtonsEnabled = false;

      if (totalEnergyConsumed <= 2000) {
        systemVoltage = 12;
      } else if (totalEnergyConsumed <= 4000) {
        systemVoltage = 24;
      } else if (totalEnergyConsumed <= 8000) {
        systemVoltage = 48;
      } else {
        systemVoltage = 60;
      }
    });
  }

  void selectRadioButton(int? value) {
    setState(() {
      recommendedVoltageSelected = false;
      radioButtonsEnabled = true;
      systemVoltage = value;
    });
  }

  void resetSelection() {
    setState(() {
      recommendedVoltageSelected = false;
      radioButtonsEnabled = true;
      systemVoltage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select your System Voltage"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Total Energy Consumed: $totalEnergyConsumed, "
                      "Energy Demand: $energyDemand, "
                      "Battery Energy Capacity: $batteryEnergyCapacity,"
                      "Battery Capacity: $batteryCapacity "
                      "Depth of Discharge: $depthOfDischarge,"
                      "Performance Ration of the Panel: $performanceRatioPanel,"
                      "Solar Energy Demand: $solarEnergyDemand,"
                      "Size of Solar Panel Array: $sizeOfSolarPanelArray,"
                      "Capacity of Each Panel: $capacityOfEachPanel,"
                      "Number of Solar Panels: $numberOfSolarPanels "),
                  Text('Don\'t know what the System Voltage is?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),),
                  Text('The system voltage determines the design, performance, '
                      'and compatibility of electrical components, such as '
                      'batteries, inverters, and appliances, within the system. '
                      'It helps ensure that the electrical equipment connected '
                      'to the system operates safely and efficiently.'),
                  ElevatedButton(
                    onPressed: selectRecommendedVoltage,
                    child: Text('Choose a Recommended Voltage'),
                  ),
                  SizedBox(height: 16.0),
                  Text("OR"),
                  SizedBox(height: 16.0),
                  Text("Choose from the options below:"),
                  SizedBox(height: 8.0),
                  RadioListTile(
                    title: Text('12V'),
                    subtitle: Text('Suitable for small-scale systems and portable setups.'),
                    value: 12,
                    groupValue: systemVoltage,
                    onChanged: radioButtonsEnabled ? selectRadioButton : null,
                  ),
                  RadioListTile(
                    title: Text('24V'),
                    subtitle: Text('Commonly used in medium-sized off-grid systems.'),
                    value: 24,
                    groupValue: systemVoltage,
                    onChanged: radioButtonsEnabled ? selectRadioButton : null,
                  ),
                  RadioListTile(
                    title: Text('48V'),
                    subtitle: Text('Ideal for larger off-grid installations with longer cable runs.'),
                    value: 48,
                    groupValue: systemVoltage,
                    onChanged: radioButtonsEnabled ? selectRadioButton : null,
                  ),
                  RadioListTile(
                    title: Text('60V'),
                    subtitle: Text('Used in commercial or industrial off-grid systems with high power requirements.'),
                    value: 60,
                    groupValue: systemVoltage,
                    onChanged: radioButtonsEnabled ? selectRadioButton : null,
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: resetSelection,
                    child: Text('Reset'),
                  ),
                  SizedBox(height: 8.0),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (systemVoltage != null) {
                            // Save the selected systemVoltage to be used in other parts of your application
                            print('Selected voltage: $systemVoltage');
                          }
                        },
                        child: Text('Save $sizeOfSolarPanelArray'),
                      ),
                      ElevatedButton(onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => SchematicDesigner()));
                      },
                          child: Text("Continue"))
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Battery Rating
//final double batteryCapacity = batteryEnergyCapacity / (systemVoltage?.toDouble() ?? 0.0);