import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medical_parameter.g.dart';

/// Enum representing the different unit systems available for medical parameters
enum UnitSystem {
  si,        // International System of Units (SI)
  conventional // Conventional Units (as used in some countries, notably the US)
}

/// Enum representing the sex context for medical parameters
/// Some medical parameters have different normal ranges based on sex
enum SexContext {
  male,
  female,
  neutral // For parameters that don't have sex-specific ranges
}

/// Enum representing the difficulty level of a medical parameter
/// Used to control which parameters appear based on user experience level
enum ParameterDifficulty {
  beginner,   // Common parameters that medical students learn first
  intermediate, // More specialized parameters
  advanced     // Rare or complex parameters
}

/// A model representing a medical parameter (lab value) in the MedStreak game
/// Includes support for different unit systems and sex-specific normal ranges
@JsonSerializable()
class MedicalParameter extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  
  // Units and conversion
  final String siUnit;
  final String conventionalUnit;
  final double conversionFactor; // To convert from SI to conventional: SI value * factor = Conventional value
  
  // Normal ranges - can be sex-specific
  final double normalRangeLowMale;
  final double normalRangeHighMale;
  final double normalRangeLowFemale;
  final double normalRangeHighFemale;
  
  // Game-related properties
  final ParameterDifficulty difficulty;
  final int pointValue;
  
  // Optional properties
  final String? imageUrl;
  final List<String>? relatedParameters;
  final Map<String, dynamic>? additionalInfo;

  const MedicalParameter({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.siUnit,
    required this.conventionalUnit,
    required this.conversionFactor,
    required this.normalRangeLowMale,
    required this.normalRangeHighMale,
    required this.normalRangeLowFemale,
    required this.normalRangeHighFemale,
    required this.difficulty,
    required this.pointValue,
    this.imageUrl,
    this.relatedParameters,
    this.additionalInfo,
  });

  /// Get the normal range for the specified sex context
  Map<String, double> getNormalRangeForSex(SexContext sexContext) {
    switch (sexContext) {
      case SexContext.male:
        return {
          'low': normalRangeLowMale,
          'high': normalRangeHighMale,
        };
      case SexContext.female:
        return {
          'low': normalRangeLowFemale,
          'high': normalRangeHighFemale,
        };
      case SexContext.neutral:
        // For neutral, we use the average of male and female ranges
        return {
          'low': (normalRangeLowMale + normalRangeLowFemale) / 2,
          'high': (normalRangeHighMale + normalRangeHighFemale) / 2,
        };
    }
  }

  /// Convert a value from SI to conventional units
  double convertSItoConventional(double siValue) {
    return siValue * conversionFactor;
  }

  /// Convert a value from conventional to SI units
  double convertConventionalToSI(double conventionalValue) {
    return conventionalValue / conversionFactor;
  }

  /// Get the appropriate unit string based on the unit system
  String getUnitString(UnitSystem unitSystem) {
    return unitSystem == UnitSystem.si ? siUnit : conventionalUnit;
  }

  /// Factory constructor to create a MedicalParameter instance from JSON
  factory MedicalParameter.fromJson(Map<String, dynamic> json) =>
      _$MedicalParameterFromJson(json);

  /// Convert MedicalParameter instance to JSON
  Map<String, dynamic> toJson() => _$MedicalParameterToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        siUnit,
        conventionalUnit,
        conversionFactor,
        normalRangeLowMale,
        normalRangeHighMale,
        normalRangeLowFemale,
        normalRangeHighFemale,
        difficulty,
        pointValue,
        imageUrl,
        relatedParameters,
        additionalInfo,
      ];
}

/// A model representing a test case in the MedStreak game
/// Each test case is a medical parameter with a specific value
@JsonSerializable()
class MedicalParameterCase extends Equatable {
  final String id;
  final MedicalParameter parameter;
  final double value; // Value in SI units
  final SexContext sexContext;
  final ParameterDifficulty difficulty;
  final String? clinicalContext;

  const MedicalParameterCase({
    required this.id,
    required this.parameter,
    required this.value,
    required this.sexContext,
    required this.difficulty,
    this.clinicalContext,
  });

  /// Get the case value in the specified unit system
  double getValueInUnitSystem(UnitSystem unitSystem) {
    if (unitSystem == UnitSystem.si) {
      return value;
    } else {
      return parameter.convertSItoConventional(value);
    }
  }

  /// Determine if the value is low, normal, or high based on the sex context
  String getValueClassification() {
    final normalRange = parameter.getNormalRangeForSex(sexContext);
    
    if (value < normalRange['low']!) {
      return 'LOW';
    } else if (value > normalRange['high']!) {
      return 'HIGH';
    } else {
      return 'NORMAL';
    }
  }

  /// Factory constructor to create a MedicalParameterCase instance from JSON
  factory MedicalParameterCase.fromJson(Map<String, dynamic> json) =>
      _$MedicalParameterCaseFromJson(json);

  /// Convert MedicalParameterCase instance to JSON
  Map<String, dynamic> toJson() => _$MedicalParameterCaseToJson(this);

  @override
  List<Object?> get props => [
        id,
        parameter,
        value,
        sexContext,
        clinicalContext,
      ];
}

/// A comprehensive list of medical parameters used in the MedStreak game
/// This will be used to populate the game with realistic medical data
class MedicalParameterRepository {
  /// Get all medical parameters
  static List<MedicalParameter> getAllParameters() {
    return [
      // Hematology Parameters
      const MedicalParameter(
        id: 'hemoglobin',
        name: 'Hemoglobin',
        description: 'Oxygen-carrying protein in red blood cells',
        category: 'Hematology',
        siUnit: 'g/L',
        conventionalUnit: 'g/dL',
        conversionFactor: 0.1,
        normalRangeLowMale: 135.0,
        normalRangeHighMale: 175.0,
        normalRangeLowFemale: 120.0,
        normalRangeHighFemale: 155.0,
        difficulty: ParameterDifficulty.beginner,
        pointValue: 5,
      ),
      const MedicalParameter(
        id: 'wbc',
        name: 'White Blood Cell Count',
        description: 'Total number of white blood cells',
        category: 'Hematology',
        siUnit: '×10^9/L',
        conventionalUnit: '×10^3/μL',
        conversionFactor: 1.0,
        normalRangeLowMale: 4.0,
        normalRangeHighMale: 11.0,
        normalRangeLowFemale: 4.0,
        normalRangeHighFemale: 11.0,
        difficulty: ParameterDifficulty.beginner,
        pointValue: 5,
      ),
      const MedicalParameter(
        id: 'platelets',
        name: 'Platelets',
        description: 'Blood cells involved in clotting',
        category: 'Hematology',
        siUnit: '×10^9/L',
        conventionalUnit: '×10^3/μL',
        conversionFactor: 1.0,
        normalRangeLowMale: 150.0,
        normalRangeHighMale: 450.0,
        normalRangeLowFemale: 150.0,
        normalRangeHighFemale: 450.0,
        difficulty: ParameterDifficulty.beginner,
        pointValue: 5,
      ),
      
      // Chemistry Parameters
      const MedicalParameter(
        id: 'sodium',
        name: 'Sodium',
        description: 'Major electrolyte in blood',
        category: 'Chemistry',
        siUnit: 'mmol/L',
        conventionalUnit: 'mEq/L',
        conversionFactor: 1.0,
        normalRangeLowMale: 135.0,
        normalRangeHighMale: 145.0,
        normalRangeLowFemale: 135.0,
        normalRangeHighFemale: 145.0,
        difficulty: ParameterDifficulty.beginner,
        pointValue: 5,
      ),
      const MedicalParameter(
        id: 'potassium',
        name: 'Potassium',
        description: 'Electrolyte crucial for heart function',
        category: 'Chemistry',
        siUnit: 'mmol/L',
        conventionalUnit: 'mEq/L',
        conversionFactor: 1.0,
        normalRangeLowMale: 3.5,
        normalRangeHighMale: 5.0,
        normalRangeLowFemale: 3.5,
        normalRangeHighFemale: 5.0,
        difficulty: ParameterDifficulty.beginner,
        pointValue: 5,
      ),
      const MedicalParameter(
        id: 'glucose',
        name: 'Glucose',
        description: 'Blood sugar level',
        category: 'Chemistry',
        siUnit: 'mmol/L',
        conventionalUnit: 'mg/dL',
        conversionFactor: 18.02,
        normalRangeLowMale: 3.9,
        normalRangeHighMale: 5.6,
        normalRangeLowFemale: 3.9,
        normalRangeHighFemale: 5.6,
        difficulty: ParameterDifficulty.beginner,
        pointValue: 5,
      ),
      const MedicalParameter(
        id: 'creatinine',
        name: 'Creatinine',
        description: 'Waste product filtered by kidneys',
        category: 'Chemistry',
        siUnit: 'μmol/L',
        conventionalUnit: 'mg/dL',
        conversionFactor: 88.4,
        normalRangeLowMale: 60.0,
        normalRangeHighMale: 110.0,
        normalRangeLowFemale: 45.0,
        normalRangeHighFemale: 90.0,
        difficulty: ParameterDifficulty.beginner,
        pointValue: 5,
      ),
      
      // Liver Function Tests
      const MedicalParameter(
        id: 'alt',
        name: 'ALT',
        description: 'Alanine aminotransferase, liver enzyme',
        category: 'Liver',
        siUnit: 'U/L',
        conventionalUnit: 'U/L',
        conversionFactor: 1.0,
        normalRangeLowMale: 5.0,
        normalRangeHighMale: 40.0,
        normalRangeLowFemale: 5.0,
        normalRangeHighFemale: 35.0,
        difficulty: ParameterDifficulty.beginner,
        pointValue: 10,
      ),
      const MedicalParameter(
        id: 'bilirubin',
        name: 'Total Bilirubin',
        description: 'Breakdown product of hemoglobin',
        category: 'Liver',
        siUnit: 'μmol/L',
        conventionalUnit: 'mg/dL',
        conversionFactor: 17.1,
        normalRangeLowMale: 3.0,
        normalRangeHighMale: 21.0,
        normalRangeLowFemale: 3.0,
        normalRangeHighFemale: 21.0,
        difficulty: ParameterDifficulty.intermediate,
        pointValue: 10,
      ),
      
      // More complex parameters
      const MedicalParameter(
        id: 'ferritin',
        name: 'Ferritin',
        description: 'Iron storage protein',
        category: 'Hematology',
        siUnit: 'μg/L',
        conventionalUnit: 'ng/mL',
        conversionFactor: 1.0,
        normalRangeLowMale: 30.0,
        normalRangeHighMale: 400.0,
        normalRangeLowFemale: 15.0,
        normalRangeHighFemale: 150.0,
        difficulty: ParameterDifficulty.intermediate,
        pointValue: 15,
      ),
      const MedicalParameter(
        id: 'tsh',
        name: 'TSH',
        description: 'Thyroid stimulating hormone',
        category: 'Endocrine',
        siUnit: 'mIU/L',
        conventionalUnit: 'μIU/mL',
        conversionFactor: 1.0,
        normalRangeLowMale: 0.4,
        normalRangeHighMale: 4.0,
        normalRangeLowFemale: 0.4,
        normalRangeHighFemale: 4.0,
        difficulty: ParameterDifficulty.intermediate,
        pointValue: 15,
      ),
      const MedicalParameter(
        id: 'troponin',
        name: 'Troponin I',
        description: 'Cardiac muscle protein',
        category: 'Cardiac',
        siUnit: 'ng/L',
        conventionalUnit: 'ng/mL',
        conversionFactor: 0.001,
        normalRangeLowMale: 0.0,
        normalRangeHighMale: 14.0,
        normalRangeLowFemale: 0.0,
        normalRangeHighFemale: 14.0,
        difficulty: ParameterDifficulty.advanced,
        pointValue: 20,
      ),
    ];
  }

  /// Get parameters filtered by difficulty
  static List<MedicalParameter> getParametersByDifficulty(ParameterDifficulty difficulty) {
    return getAllParameters()
        .where((param) => param.difficulty == difficulty)
        .toList();
  }

  /// Get parameters filtered by category
  static List<MedicalParameter> getParametersByCategory(String category) {
    return getAllParameters()
        .where((param) => param.category == category)
        .toList();
  }

  /// Get a specific parameter by ID
  static MedicalParameter? getParameterById(String id) {
    try {
      return getAllParameters().firstWhere((param) => param.id == id);
    } catch (e) {
      return null;
    }
  }
}
