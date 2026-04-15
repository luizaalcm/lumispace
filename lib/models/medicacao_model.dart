import 'package:cloud_firestore/cloud_firestore.dart';

class MedicacaoModel {
  const MedicacaoModel({
    required this.id,
    required this.userId,
    required this.nome,
    required this.dosagem,
    required this.frequencia,
    required this.criadoEm,
  });

  final String id;
  final String userId;
  final String nome;
  final String dosagem;
  final String frequencia;
  final DateTime criadoEm;

  factory MedicacaoModel.fromMap(String id, Map<String, dynamic> map) {
    return MedicacaoModel(
      id: id,
      userId: map['userId'] as String,
      nome: map['nome'] as String? ?? '',
      dosagem: map['dosagem'] as String? ?? '',
      frequencia: map['frequencia'] as String? ?? '',
      criadoEm: (map['criadoEm'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'nome': nome,
      'dosagem': dosagem,
      'frequencia': frequencia,
      'criadoEm': Timestamp.fromDate(criadoEm),
    };
  }
}
