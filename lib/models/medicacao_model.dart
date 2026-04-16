import 'package:cloud_firestore/cloud_firestore.dart';

class MedicacaoModel {
  const MedicacaoModel({
    required this.id,
    required this.userId,
    required this.nome,
    required this.dosagem,
    required this.frequencia,
    this.horarioLembrete,
    this.lembreteAtivo = false,
    required this.criadoEm,
  });

  final String id;
  final String userId;
  final String nome;
  final String dosagem;
  final String frequencia;
  final String? horarioLembrete;
  final bool lembreteAtivo;
  final DateTime criadoEm;

  factory MedicacaoModel.fromMap(String id, Map<String, dynamic> map) {
    return MedicacaoModel(
      id: id,
      userId: map['userId'] as String,
      nome: map['nome'] as String? ?? '',
      dosagem: map['dosagem'] as String? ?? '',
      frequencia: map['frequencia'] as String? ?? '',
      horarioLembrete: map['horarioLembrete'] as String?,
      lembreteAtivo: map['lembreteAtivo'] as bool? ?? false,
      criadoEm: (map['criadoEm'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'nome': nome,
      'dosagem': dosagem,
      'frequencia': frequencia,
      'horarioLembrete': horarioLembrete,
      'lembreteAtivo': lembreteAtivo,
      'criadoEm': Timestamp.fromDate(criadoEm),
    };
  }

  MedicacaoModel copyWith({
    String? id,
    String? userId,
    String? nome,
    String? dosagem,
    String? frequencia,
    String? horarioLembrete,
    bool? lembreteAtivo,
    DateTime? criadoEm,
    bool clearHorarioLembrete = false,
  }) {
    return MedicacaoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nome: nome ?? this.nome,
      dosagem: dosagem ?? this.dosagem,
      frequencia: frequencia ?? this.frequencia,
      horarioLembrete:
          clearHorarioLembrete ? null : (horarioLembrete ?? this.horarioLembrete),
      lembreteAtivo: lembreteAtivo ?? this.lembreteAtivo,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }
}
