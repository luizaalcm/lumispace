import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroModel {
  const RegistroModel({
    required this.id,
    required this.userId,
    required this.data,
    required this.corHumor,
    required this.medicacoesSelecionadas,
    required this.naoTomouMedicacoes,
    required this.emocoes,
    required this.impulsos,
    required this.seMachucouHoje,
    required this.pediuAjuda,
    required this.relato,
    required this.criadoEm,
  });

  final String id;
  final String userId;
  final DateTime data;
  final String corHumor;
  final List<String> medicacoesSelecionadas;
  final bool naoTomouMedicacoes;
  final Map<String, int> emocoes;
  final Map<String, int> impulsos;
  final bool seMachucouHoje;
  final bool pediuAjuda;
  final String relato;
  final DateTime criadoEm;

  factory RegistroModel.fromMap(String id, Map<String, dynamic> map) {
    return RegistroModel(
      id: id,
      userId: map['userId'] as String,
      data: (map['data'] as Timestamp).toDate(),
      corHumor: map['corHumor'] as String,
      medicacoesSelecionadas:
          List<String>.from(map['medicacoesSelecionadas'] ?? const []),
      naoTomouMedicacoes: map['naoTomouMedicacoes'] as bool? ?? false,
      emocoes: Map<String, int>.from(map['emocoes'] ?? const {}),
      impulsos: Map<String, int>.from(map['impulsos'] ?? const {}),
      seMachucouHoje: map['seMachucouHoje'] as bool? ?? false,
      pediuAjuda: map['pediuAjuda'] as bool? ?? false,
      relato: map['relato'] as String? ?? '',
      criadoEm: (map['criadoEm'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'data': Timestamp.fromDate(data),
      'corHumor': corHumor,
      'medicacoesSelecionadas': medicacoesSelecionadas,
      'naoTomouMedicacoes': naoTomouMedicacoes,
      'emocoes': emocoes,
      'impulsos': impulsos,
      'seMachucouHoje': seMachucouHoje,
      'pediuAjuda': pediuAjuda,
      'relato': relato,
      'criadoEm': Timestamp.fromDate(criadoEm),
    };
  }
}
