import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/medicacao_model.dart';
import '../models/registro_model.dart';

class RegistroService {
  RegistroService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<List<RegistroModel>> observarRegistros(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('registros')
        .orderBy('data', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RegistroModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> salvarRegistro(RegistroModel registro) async {
    await _db
        .collection('users')
        .doc(registro.userId)
        .collection('registros')
        .add(registro.toMap());
  }

  Future<int> contarRegistros(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('registros')
        .get();
    return snapshot.docs.length;
  }

  Stream<List<MedicacaoModel>> observarMedicacoes(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('medicacoes')
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MedicacaoModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<MedicacaoModel> salvarMedicacao(MedicacaoModel medicacao) async {
    final ref = await _db
        .collection('users')
        .doc(medicacao.userId)
        .collection('medicacoes')
        .add(medicacao.toMap());
    return medicacao.copyWith(id: ref.id);
  }

  Future<void> atualizarMedicacao(MedicacaoModel medicacao) async {
    await _db
        .collection('users')
        .doc(medicacao.userId)
        .collection('medicacoes')
        .doc(medicacao.id)
        .update(medicacao.toMap());
  }

  Future<void> excluirMedicacao({
    required String userId,
    required String medicacaoId,
  }) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('medicacoes')
        .doc(medicacaoId)
        .delete();
  }
}
