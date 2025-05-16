import 'package:energize/boxes.dart';
import 'package:flutter/material.dart';
import 'energy_demand.dart';

double? pHSvalue;

class LocationRoute extends StatelessWidget {

  const LocationRoute({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'What is your location?'
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: MyDropdownMenu(),
        ),
      ),
    );
  }
}

class Location {
  final String name;
  final double number;


  Location({required this.name, required this.number});
}

class MyDropdownMenu extends StatefulWidget {
  @override
  _MyDropdownMenuState createState() => _MyDropdownMenuState();
}

class _MyDropdownMenuState extends State<MyDropdownMenu> {
  List<String> panelType = ['Monocrystalline', 'Polycrstalline', 'Amorphous'];
  String? selectedOption;
  //double? pHSvalue;
  String? selectedPanel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<Location>(
              value: null,
              hint: Text(selectedOption ?? 'Select a location'),
              onChanged: (Location? value) {
                setState(() {
                  selectedOption = value?.name ?? 'Select a location';
                  pHSvalue = value?.number ?? 0.0;
                  if (pHSvalue == 6.0)
                  {
                    selectedPanel = panelType[2];
                  }
                  else if (pHSvalue == 5.5 || pHSvalue == 5.0)
                  {
                    selectedPanel = panelType[1];
                  }
                  else
                  {
                    selectedPanel = panelType[0];
                  }
                });
              },
              items: [
                DropdownMenuItem(
                  value: Location(name: 'Abuja', number: 5.0),
                  child: Text('Abuja'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Abia', number: 4.0),
                  child: Text('Abia'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Adamawa', number: 5.5),
                  child: Text('Adamawa'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Akwa Ibom', number: 4.0),
                  child: Text('Akwa Ibom'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Anambra', number: 4.5),
                  child: Text('Anambra'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Bauchi', number: 5.0),
                  child: Text('Bauchi'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Bayelsa', number: 4.0),
                  child: Text('Bayelsa'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Benue', number: 5.0),
                  child: Text('Benue'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Bornu', number: 6.0),
                  child: Text('Bornu'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Cross River', number: 4.0),
                  child: Text('Cross River'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Delta', number: 4.0),
                  child: Text('Delta'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Ebonyi', number: 4.5),
                  child: Text('Ebonyi'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Edo', number: 4.5),
                  child: Text('Edo'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Ekiti', number: 4.5),
                  child: Text('Ekiti'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Enugu', number: 4.5),
                  child: Text('Enugu'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Gombe', number: 5.0),
                  child: Text('Gombe'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Imo', number: 4.0),
                  child: Text('Imo'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Jigawa', number: 5.5),
                  child: Text('Jigawa'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Kaduna', number: 5.0),
                  child: Text('Kaduna'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Kano', number: 5.5),
                  child: Text('Kano'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Katsina', number: 5.5),
                  child: Text('Katsina'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Kebbi', number: 5.5),
                  child: Text('Kebbi'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Kogi', number: 5.0),
                  child: Text('Kogi'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Kwara', number: 4.5),
                  child: Text('Kwara'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Lagos', number: 4.5),
                  child: Text('Lagos'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Nassarawa', number: 5.0),
                  child: Text('Nasarawa'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Niger', number: 5.0),
                  child: Text('Niger'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Ogun', number: 4.5),
                  child: Text('Ogun'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Ondo', number: 4.5),
                  child: Text('Ondo'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Osun', number: 4.5),
                  child: Text('Osun'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Oyo', number: 4.5),
                  child: Text('Oyo'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Plateau', number: 5.0),
                  child: Text('Plateau'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Rivers', number: 4.0),
                  child: Text('Rivers'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Sokoto', number: 6),
                  child: Text('Sokoto'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Taraba', number: 5.5),
                  child: Text('Taraba'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Yobe', number: 6.0),
                  child: Text('Yobe'),
                ),
                DropdownMenuItem(
                  value: Location(name: 'Zamfara', number: 5.5),
                  child: Text('Zamfara'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(selectedOption != null ? 'Selected Location: $selectedOption' : 'No option selected'),
            SizedBox(
              height: 5,
            ),
            Text("Peak Sun Hours (PSH) = $pHSvalue"),
            SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 5,
            ),
            Text("Recommened Panel Type = $selectedPanel"),
            ElevatedButton(
              onPressed: () {
                if (pHSvalue != null) {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => EnergyDemand()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Select a Location'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text("Continue"),
            )
          ],
        ),
      ),
    );
  }
}



