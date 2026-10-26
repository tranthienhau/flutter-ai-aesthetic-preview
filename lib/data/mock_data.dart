import '../models/models.dart';

const hairStyles = [
  ('Long layers', 'assets/images/style-long-layers.jpg'),
  ('Soft bob', 'assets/images/style-soft-bob.jpg'),
  ('Curtain bangs', 'assets/images/style-curtain-bangs.jpg'),
  ('Pixie', 'assets/images/style-pixie.jpg'),
  ('Beach waves', 'assets/images/style-beach-waves.jpg'),
  ('Sleek ponytail', 'assets/images/style-ponytail.jpg'),
];

const hairColors = [
  ('Natural', 0xFF3B2A20),
  ('Honey blonde', 0xFFC8955A),
  ('Chestnut', 0xFF7A4528),
  ('Copper', 0xFFB4592A),
  ('Ash', 0xFF8C8478),
];

const makeupLooks = [
  ('Soft glam', 'assets/images/tile-makeup.jpg'),
  ('No-makeup look', 'assets/images/hist-2.jpg'),
  ('Evening', 'assets/images/avatar-yael.jpg'),
];

List<Preview> seedPreviews() => [
      Preview(
        id: 's1',
        request: const SimulationRequest(
            type: SimulationType.hair, photoAsset: 'assets/sim/before.jpg', hairStyle: 'Sleek ponytail', hairColor: 'Copper'),
        beforeAsset: 'assets/sim/before.jpg',
        afterAsset: 'assets/sim/after-hair-copper.jpg',
        createdAt: DateTime(2026, 10, 26, 11, 20),
        sharedWithClinic: true,
      ),
      Preview(
        id: 's2',
        request: const SimulationRequest(
            type: SimulationType.filler,
            photoAsset: 'assets/sim/before.jpg',
            area: TreatmentArea.lips,
            amount: 1.0),
        beforeAsset: 'assets/sim/before.jpg',
        afterAsset: 'assets/sim/after-lips.jpg',
        createdAt: DateTime(2026, 10, 26, 11, 5),
        sharedWithClinic: true,
      ),
      Preview(
        id: 's3',
        request: const SimulationRequest(
            type: SimulationType.makeup, photoAsset: 'assets/sim/before.jpg', makeupLook: 'Soft glam'),
        beforeAsset: 'assets/sim/before.jpg',
        afterAsset: 'assets/sim/after-makeup.jpg',
        createdAt: DateTime(2026, 10, 24, 18, 40),
      ),
      Preview(
        id: 's4',
        request: const SimulationRequest(
            type: SimulationType.filler,
            photoAsset: 'assets/sim/before.jpg',
            area: TreatmentArea.cheeks,
            amount: 1.5),
        beforeAsset: 'assets/sim/before.jpg',
        afterAsset: 'assets/images/hist-4.jpg',
        createdAt: DateTime(2026, 10, 22, 9, 15),
      ),
    ];

const clinicSessions = [
  ClinicSession(
      client: 'Noa Levi', avatar: 'assets/images/avatar-noa.jpg', time: '10:30', treatment: 'Lip filler 1.0 ml', shared: true),
  ClinicSession(
      client: 'Maya Cohen', avatar: 'assets/images/avatar-maya.jpg', time: '11:15', treatment: 'Cheek filler 1.5 ml', shared: true),
  ClinicSession(
      client: 'Yael Mizrahi', avatar: 'assets/images/avatar-yael.jpg', time: '12:00', treatment: 'Sleek ponytail + copper', shared: false),
  ClinicSession(
      client: 'Tamar Ben-David', avatar: 'assets/images/hist-4.jpg', time: '13:30', treatment: 'Forehead Botox 20 units', shared: true),
];

String shortDate(DateTime d) {
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${m[d.month - 1]} ${d.day}';
}

String longDate(DateTime d) => '${shortDate(d)}, ${d.year}';
