import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoUsuario { paciente, profissional }

enum ConselhoProfissional { crp, crm }

class UsuarioModel {
  final String uid;
  final String nome;
  final String email;
  final TipoUsuario tipo;
  final DateTime dataNascimento;
  final String codigo;
  final ConselhoProfissional? conselhoProfissional;
  final String? registroProfissional;
  final String? especialidade;
  final List<String> pacientesVinculados;
  final List<String> profissionaisVinculados;
  final String? fotoPerfil;
  final DateTime criadoEm;

  const UsuarioModel({
    required this.uid,
    required this.nome,
    required this.email,
    required this.tipo,
    required this.dataNascimento,
    required this.codigo,
    this.conselhoProfissional,
    this.registroProfissional,
    this.especialidade,
    this.pacientesVinculados = const [],
    this.profissionaisVinculados = const [],
    this.fotoPerfil,
    required this.criadoEm,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      uid: map['uid'] as String,
      nome: map['nome'] as String,
      email: map['email'] as String,
      tipo: map['tipo'] == 'profissional'
          ? TipoUsuario.profissional
          : TipoUsuario.paciente,
      dataNascimento: (map['dataNascimento'] as Timestamp).toDate(),
      codigo: map['codigo'] as String,
      conselhoProfissional: _conselhoFromString(map['conselhoProfissional']),
      registroProfissional: map['registroProfissional'] as String?,
      especialidade: map['especialidade'] as String?,
      pacientesVinculados:
          List<String>.from(map['pacientesVinculados'] ?? const []),
      profissionaisVinculados:
          List<String>.from(map['profissionaisVinculados'] ?? const []),
      fotoPerfil: map['fotoPerfil'] as String?,
      criadoEm: (map['criadoEm'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email,
      'tipo': tipo.name,
      'dataNascimento': Timestamp.fromDate(dataNascimento),
      'codigo': codigo,
      'conselhoProfissional': conselhoProfissional?.name,
      'registroProfissional': registroProfissional,
      'especialidade': especialidade,
      'pacientesVinculados': pacientesVinculados,
      'profissionaisVinculados': profissionaisVinculados,
      'fotoPerfil': fotoPerfil,
      'criadoEm': Timestamp.fromDate(criadoEm),
    };
  }

  UsuarioModel copyWith({
    String? nome,
    String? email,
    String? codigo,
    String? registroProfissional,
    String? especialidade,
    String? fotoPerfil,
    List<String>? pacientesVinculados,
    List<String>? profissionaisVinculados,
  }) {
    return UsuarioModel(
      uid: uid,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      tipo: tipo,
      dataNascimento: dataNascimento,
      codigo: codigo ?? this.codigo,
      conselhoProfissional: conselhoProfissional,
      registroProfissional: registroProfissional ?? this.registroProfissional,
      especialidade: especialidade ?? this.especialidade,
      pacientesVinculados: pacientesVinculados ?? this.pacientesVinculados,
      profissionaisVinculados:
          profissionaisVinculados ?? this.profissionaisVinculados,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      criadoEm: criadoEm,
    );
  }

  static ConselhoProfissional? _conselhoFromString(dynamic value) {
    if (value == null) return null;

    for (final conselho in ConselhoProfissional.values) {
      if (conselho.name == value) {
        return conselho;
      }
    }

    return null;
  }
}
