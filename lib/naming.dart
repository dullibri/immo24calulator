import 'dart:math';

String naming() {
  List animals = [
    'Affen',
    'Hunde',
    'Katzen',
    'Hahnen',
    'Kröten',
    'Frosch',
    'Hai',
    'Pferde',
    'Känguru',
    'Löwen'
  ];
  List things = [
    'Fahrrad',
    'Rakete',
    'Käfig',
    'Auto',
    'Stuhl',
    'Haus',
    'Handy',
    'Roller'
  ];
  Random random = Random();

  int randomAnimalIndex = random.nextInt(animals.length);
  int randomFarbenIndex = random.nextInt(things.length);

  String randomAnimal = animals[randomAnimalIndex];
  String randomFarbe = things[randomFarbenIndex];

  return '$randomAnimal-$randomFarbe';
}
