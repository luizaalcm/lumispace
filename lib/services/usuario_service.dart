import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/usuario_model.dart';

class UsuarioService {
  UsuarioService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String _gerarCodigo() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<UsuarioModel> criarUsuario({
    required String nome,
    required String email,
    required String senha,
    required TipoUsuario tipo,
    required DateTime dataNascimento,
    ConselhoProfissional? conselhoProfissional,
    String? registroProfissional,
    String? especialidade,
  }) async {
    final emailNormalizado = email.trim().toLowerCase();
    final credential = await _auth.createUserWithEmailAndPassword(
      email: emailNormalizado,
      password: senha,
    );

    final uid = credential.user!.uid;
    final usuario = UsuarioModel(
      uid: uid,
      nome: nome,
      email: emailNormalizado,
      tipo: tipo,
      dataNascimento: dataNascimento,
      codigo: _gerarCodigo(),
      conselhoProfissional: conselhoProfissional,
      registroProfissional: registroProfissional,
      especialidade: especialidade,
      criadoEm: DateTime.now(),
    );

    await _db.collection('users').doc(uid).set(usuario.toMap());
    return usuario;
  }

  Future<UsuarioModel> fazerLogin({
    required String email,
    required String senha,
    required TipoUsuario tipoEsperado,
  }) async {
    try {
      final emailNormalizado = email.trim().toLowerCase();
      final credential = await _auth.signInWithEmailAndPassword(
        email: emailNormalizado,
        password: senha,
      );

      final uid = credential.user!.uid;
      final usuario = await buscarUsuario(uid);

      if (usuario == null) {
        await _auth.signOut();
        throw Exception('Conta inexistente. Essa conta nao esta mais disponivel.');
      }

      if (usuario.tipo != tipoEsperado) {
        await _auth.signOut();
        throw Exception('Esse login nao corresponde ao perfil selecionado.');
      }

      return usuario;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception(
          'Conta inexistente. Verifique o email ou crie uma nova conta.',
        );
      }
      if (e.code == 'wrong-password') {
        throw Exception('Senha incorreta.');
      }
      if (e.code == 'invalid-credential') {
        throw Exception('Email ou senha incorretos.');
      }
      throw Exception('Nao foi possivel fazer login.');
    }
  }

  Future<void> enviarRedefinicaoSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw Exception('Informe um email valido.');
      }
      if (e.code == 'user-not-found') {
        throw Exception('Nao existe conta cadastrada com esse email.');
      }
      throw Exception('Nao foi possivel enviar o email de redefinicao.');
    }
  }

  Future<UsuarioModel?> buscarUsuario(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UsuarioModel.fromMap(doc.data()!);
  }

  Future<List<UsuarioModel>> buscarUsuariosPorIds(List<String> ids) async {
    final usuarios = await Future.wait(ids.map(buscarUsuario));
    return usuarios.whereType<UsuarioModel>().toList();
  }

  Future<UsuarioModel?> buscarPorCodigo(String codigo) async {
    final query = await _db
        .collection('users')
        .where('codigo', isEqualTo: codigo)
        .where('tipo', isEqualTo: 'paciente')
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return UsuarioModel.fromMap(query.docs.first.data());
  }

  Future<void> vincularPacienteAoProfissional({
    required String pacienteId,
    required String profissionalId,
  }) async {
    final pacienteRef = _db.collection('users').doc(pacienteId);
    final profissionalRef = _db.collection('users').doc(profissionalId);

    await _db.runTransaction((transaction) async {
      final pacienteDoc = await transaction.get(pacienteRef);
      final profissionalDoc = await transaction.get(profissionalRef);

      if (!pacienteDoc.exists || !profissionalDoc.exists) {
        throw Exception('Paciente ou profissional nao encontrado.');
      }

      final paciente = UsuarioModel.fromMap(pacienteDoc.data()!);
      final profissional = UsuarioModel.fromMap(profissionalDoc.data()!);

      if (paciente.tipo != TipoUsuario.paciente ||
          profissional.tipo != TipoUsuario.profissional) {
        throw Exception('Os perfis informados nao podem ser vinculados.');
      }

      transaction.update(pacienteRef, {
        'profissionaisVinculados': FieldValue.arrayUnion([profissionalId]),
      });
      transaction.update(profissionalRef, {
        'pacientesVinculados': FieldValue.arrayUnion([pacienteId]),
      });
    });
  }

  Future<void> desvincularPacienteDoProfissional({
    required String pacienteId,
    required String profissionalId,
  }) async {
    await _db.collection('users').doc(pacienteId).update({
      'profissionaisVinculados': FieldValue.arrayRemove([profissionalId]),
    });
    await _db.collection('users').doc(profissionalId).update({
      'pacientesVinculados': FieldValue.arrayRemove([pacienteId]),
    });
  }

  Future<void> sair() async {
    await _auth.signOut();
  }

  Future<UsuarioModel> atualizarPerfil({
    required UsuarioModel usuario,
    String? nome,
    String? email,
    String? fotoPerfil,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Sessao expirada. Entre novamente.');
    }

    final novoNome = nome?.trim().isNotEmpty == true ? nome!.trim() : usuario.nome;
    final novoEmail =
        email?.trim().isNotEmpty == true
            ? email!.trim().toLowerCase()
            : usuario.email.toLowerCase();
    final novaFoto = fotoPerfil ?? usuario.fotoPerfil;

    if (novoEmail != usuario.email) {
      try {
        await user.verifyBeforeUpdateEmail(novoEmail);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          throw Exception('Esse email ja esta em uso.');
        }
        if (e.code == 'requires-recent-login') {
          throw Exception(
            'Por seguranca, faca login novamente antes de trocar o email.',
          );
        }
        throw Exception('Nao foi possivel atualizar o email.');
      }
    }

    await _db.collection('users').doc(usuario.uid).update({
      'nome': novoNome,
      'email': novoEmail,
      'fotoPerfil': novaFoto,
    });

    return usuario.copyWith(
      nome: novoNome,
      email: novoEmail,
      fotoPerfil: novaFoto,
    );
  }

  Future<void> alterarSenha({
    required String novaSenha,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Sessao expirada. Entre novamente.');
    }

    try {
      await user.updatePassword(novaSenha);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('A nova senha precisa ter pelo menos 6 caracteres.');
      }
      if (e.code == 'requires-recent-login') {
        throw Exception(
          'Por seguranca, faca login novamente antes de trocar a senha.',
        );
      }
      throw Exception('Nao foi possivel atualizar a senha.');
    }
  }

  Future<void> excluirConta(UsuarioModel usuario) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Sessao expirada. Entre novamente.');
    }

    try {
      final usuarioAtual = await buscarUsuario(usuario.uid) ?? usuario;

      await _removerVinculosDoUsuario(usuarioAtual);
      await _apagarSubcolecao(usuario.uid, 'registros');
      await _apagarSubcolecao(usuario.uid, 'medicacoes');
      await _db.collection('users').doc(usuario.uid).delete();
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
          'Por seguranca, faca login novamente antes de excluir a conta.',
        );
      }
      throw Exception('Nao foi possivel excluir a conta.');
    }
  }

  Future<void> _removerVinculosDoUsuario(UsuarioModel usuario) async {
    if (usuario.profissionaisVinculados.isNotEmpty) {
      for (final profissionalId in usuario.profissionaisVinculados) {
        try {
          await _db.collection('users').doc(profissionalId).update({
            'pacientesVinculados': FieldValue.arrayRemove([usuario.uid]),
          });
        } catch (_) {
          // Mantemos a exclusao da conta mesmo se um vinculo externo falhar.
        }
      }
    }

    if (usuario.pacientesVinculados.isNotEmpty) {
      for (final pacienteId in usuario.pacientesVinculados) {
        try {
          await _db.collection('users').doc(pacienteId).update({
            'profissionaisVinculados': FieldValue.arrayRemove([usuario.uid]),
          });
        } catch (_) {
          // Mantemos a exclusao da conta mesmo se um vinculo externo falhar.
        }
      }
    }
  }

  Future<void> _apagarSubcolecao(String userId, String nomeSubcolecao) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection(nomeSubcolecao)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
