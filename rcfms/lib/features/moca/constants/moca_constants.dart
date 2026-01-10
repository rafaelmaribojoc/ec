/// MoCA-P (Montreal Cognitive Assessment) Constants
class MocaConstants {
  MocaConstants._();

  // App Info
  static const String appName = 'MoCA-P';
  static const String appVersion = '1.0.0';

  // MoCA Test Constants
  static const int totalPoints = 30;
  static const int normalThreshold = 26;
  static const int educationAdjustmentYears = 12;

  // Section Points
  static const int visuospatialPoints = 5;
  static const int namingPoints = 3;
  static const int attentionPoints = 6;
  static const int languagePoints = 3;
  static const int abstractionPoints = 2;
  static const int delayedRecallPoints = 5;
  static const int orientationPoints = 6;

  // Memory Words
  static const List<String> memoryWords = [
    'FACE',
    'VELVET',
    'CHURCH',
    'DAISY',
    'RED',
  ];

  // Attention - Digit Sequences
  static const List<int> digitSpanForward = [2, 1, 8, 5, 4];
  static const List<int> digitSpanBackward = [7, 4, 2];

  // Attention - Letter Sequence for Vigilance
  static const String vigilanceLetters = 'FBACMNAAJKLBAFAKDEAAAJAMOFAAB';
  static const String targetLetter = 'A';

  // Serial 7s
  static const int serial7Start = 100;
  static const List<int> serial7Answers = [93, 86, 79, 72, 65];

  // Language - Sentences for Repetition
  static const List<String> repetitionSentences = [
    'I only know that John is the one to help today.',
    'The cat always hid under the couch when dogs were in the room.',
  ];

  // Abstraction Pairs
  static const List<Map<String, dynamic>> abstractionPairs = [
    {
      'item1': 'train',
      'item2': 'bicycle',
      'acceptedAnswers': [
        'transportation',
        'transport',
        'means of transportation',
        'vehicles',
        'travel',
        'ways to travel',
      ],
    },
    {
      'item1': 'watch',
      'item2': 'ruler',
      'acceptedAnswers': [
        'measuring',
        'measurement',
        'measuring instruments',
        'measuring devices',
        'tools for measuring',
      ],
    },
  ];

  // Naming Animals
  static const List<String> namingAnimals = ['lion', 'rhinoceros', 'camel'];

  // Fluency Test
  static const String fluencyLetter = 'F';
  static const int fluencyDurationSeconds = 60;
  static const int fluencyMinimumWords = 11;

  // Storage Keys
  static const String assessmentBoxKey = 'moca_assessment_box';
}
