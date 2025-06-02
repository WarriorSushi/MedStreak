// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicalParameter _$MedicalParameterFromJson(Map<String, dynamic> json) =>
    MedicalParameter(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      siUnit: json['siUnit'] as String,
      conventionalUnit: json['conventionalUnit'] as String,
      conversionFactor: (json['conversionFactor'] as num).toDouble(),
      normalRangeLowMale: (json['normalRangeLowMale'] as num).toDouble(),
      normalRangeHighMale: (json['normalRangeHighMale'] as num).toDouble(),
      normalRangeLowFemale: (json['normalRangeLowFemale'] as num).toDouble(),
      normalRangeHighFemale: (json['normalRangeHighFemale'] as num).toDouble(),
      difficulty: $enumDecode(_$ParameterDifficultyEnumMap, json['difficulty']),
      pointValue: (json['pointValue'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
      relatedParameters: (json['relatedParameters'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MedicalParameterToJson(MedicalParameter instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'siUnit': instance.siUnit,
      'conventionalUnit': instance.conventionalUnit,
      'conversionFactor': instance.conversionFactor,
      'normalRangeLowMale': instance.normalRangeLowMale,
      'normalRangeHighMale': instance.normalRangeHighMale,
      'normalRangeLowFemale': instance.normalRangeLowFemale,
      'normalRangeHighFemale': instance.normalRangeHighFemale,
      'difficulty': _$ParameterDifficultyEnumMap[instance.difficulty]!,
      'pointValue': instance.pointValue,
      'imageUrl': instance.imageUrl,
      'relatedParameters': instance.relatedParameters,
      'additionalInfo': instance.additionalInfo,
    };

const _$ParameterDifficultyEnumMap = {
  ParameterDifficulty.beginner: 'beginner',
  ParameterDifficulty.intermediate: 'intermediate',
  ParameterDifficulty.advanced: 'advanced',
};

MedicalParameterCase _$MedicalParameterCaseFromJson(
        Map<String, dynamic> json) =>
    MedicalParameterCase(
      id: json['id'] as String,
      parameter:
          MedicalParameter.fromJson(json['parameter'] as Map<String, dynamic>),
      value: (json['value'] as num).toDouble(),
      sexContext: $enumDecode(_$SexContextEnumMap, json['sexContext']),
      difficulty: $enumDecode(_$ParameterDifficultyEnumMap, json['difficulty']),
      clinicalContext: json['clinicalContext'] as String?,
    );

Map<String, dynamic> _$MedicalParameterCaseToJson(
        MedicalParameterCase instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parameter': instance.parameter,
      'value': instance.value,
      'sexContext': _$SexContextEnumMap[instance.sexContext]!,
      'difficulty': _$ParameterDifficultyEnumMap[instance.difficulty]!,
      'clinicalContext': instance.clinicalContext,
    };

const _$SexContextEnumMap = {
  SexContext.male: 'male',
  SexContext.female: 'female',
  SexContext.neutral: 'neutral',
};
