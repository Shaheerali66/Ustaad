import 'lib/data/technicians_data.dart';

void main() {
  final list = TechnicianDataset.technicians;
  final counts = <String, Map<String, int>>{};
  
  for (var tech in list) {
    final city = tech['city'] as String;
    final cat = tech['category'] as String;
    if (!counts.containsKey(city)) {
      counts[city] = {};
    }
    counts[city]![cat] = (counts[city]![cat] ?? 0) + 1;
  }
  
  print('Technicians counts per (City, Category):');
  counts.forEach((city, catMap) {
    print('City: $city');
    catMap.forEach((cat, count) {
      print(' - $cat: $count');
    });
  });
}
