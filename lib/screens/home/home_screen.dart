import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/medicacao_model.dart';
import '../../models/registro_model.dart';
import '../../models/usuario_model.dart';
import '../../services/usuario_service.dart';
import '../auth/auth_screen.dart';
import '../../services/registro_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.usuario});

  final UsuarioModel usuario;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _registroService = RegistroService();
  final _usuarioService = UsuarioService();
  int _currentIndex = 0;
  late UsuarioModel _usuarioAtual;

  @override
  void initState() {
    super.initState();
    _usuarioAtual = widget.usuario;
  }

  bool get _isPaciente => _usuarioAtual.tipo == TipoUsuario.paciente;

  List<_NavConfig> get _navItems {
    if (_isPaciente) {
      return const [
        _NavConfig('Home', Icons.home_outlined, Icons.home_filled),
        _NavConfig('Registrar', Icons.edit_note_rounded, Icons.edit_note_rounded),
        _NavConfig('Medicação', Icons.medication_outlined, Icons.medication),
        _NavConfig('Configurações', Icons.settings_outlined, Icons.settings),
      ];
    }

    return const [
      _NavConfig('Home', Icons.home_outlined, Icons.home_filled),
      _NavConfig('Pacientes', Icons.groups_outlined, Icons.groups),
      _NavConfig('Configurações', Icons.settings_outlined, Icons.settings),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pages = _isPaciente
        ? [
            _PatientHomeTab(
              usuario: _usuarioAtual,
              onAvatarTap: () => setState(() => _currentIndex = 3),
            ),
            _PatientRegistroTab(
              usuario: _usuarioAtual,
              registroService: _registroService,
            ),
            _MedicacaoTab(
              usuario: _usuarioAtual,
              registroService: _registroService,
            ),
            _SettingsTab(
              usuario: _usuarioAtual,
              onPerfilAtualizado: (usuario) {
                setState(() => _usuarioAtual = usuario);
              },
              onSair: _sair,
              onExcluirConta: _excluirConta,
              usuarioService: _usuarioService,
            ),
          ]
        : [
            _ProfessionalHomeTab(
              usuario: _usuarioAtual,
              onAvatarTap: () => setState(() => _currentIndex = 2),
            ),
            _ProfessionalPatientsTab(
              usuario: _usuarioAtual,
              usuarioService: _usuarioService,
              registroService: _registroService,
            ),
            _SettingsTab(
              usuario: _usuarioAtual,
              onPerfilAtualizado: (usuario) {
                setState(() => _usuarioAtual = usuario);
              },
              onSair: _sair,
              onExcluirConta: _excluirConta,
              usuarioService: _usuarioService,
            ),
          ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FB),
      body: pages[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(top: BorderSide(color: Color(0xFFE9E5F2))),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              return _NavItem(
                icon: item.icon,
                activeIcon: item.activeIcon,
                label: item.label,
                selected: _currentIndex == index,
                onTap: () => setState(() => _currentIndex = index),
              );
            }),
          ),
        ),
      ),
    );
  }

  Future<void> _sair() async {
    await _usuarioService.sair();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  Future<void> _excluirConta() async {
    await _usuarioService.excluirConta(_usuarioAtual);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }
}

class _PatientHomeTab extends StatelessWidget {
  const _PatientHomeTab({
    required this.usuario,
    required this.onAvatarTap,
  });

  final UsuarioModel usuario;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    const cards = [
      _HomeCardData(
        title: 'O que é Transtorno de Personalidade Borderline',
        subtitle: 'texto explicando',
        color: Color(0xFFFFDDE3),
      ),
      _HomeCardData(
        title: 'Técnicas de Regulação',
        subtitle: 'texto explicando',
        color: Color(0xFFD8CCF8),
      ),
      _HomeCardData(
        title: 'A importância da escrita terapêutica',
        subtitle: 'texto explicando',
        color: Color(0xFFDDF3D7),
      ),
      _HomeCardData(
        title: 'Terapia Cognitivo Comportamental',
        subtitle: 'texto explicando',
        color: Color(0xFFDCEFF8),
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(usuario: usuario, onAvatarTap: onAvatarTap),
            const SizedBox(height: 20),
            Text(
              'Olá, ${usuario.nome}. Vamos aprender algo novo hoje?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF5D585C),
                    height: 1.2,
                  ),
            ),
            const SizedBox(height: 22),
            Text(
              'Entendendo o TPB',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF58535A),
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 12,
                childAspectRatio: 1.02,
              ),
              itemBuilder: (context, index) => _ContentCard(data: cards[index]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfessionalHomeTab extends StatelessWidget {
  const _ProfessionalHomeTab({
    required this.usuario,
    required this.onAvatarTap,
  });

  final UsuarioModel usuario;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(usuario: usuario, onAvatarTap: onAvatarTap),
            const SizedBox(height: 20),
            Text(
              'Olá, ${usuario.nome}.',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF5D585C),
                  ),
            ),
            const SizedBox(height: 14),
            Text(
              'Seu código profissional é ${usuario.codigo}. Use a aba de pacientes para acompanhar vínculos e acessos.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF7A7680),
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientRegistroTab extends StatefulWidget {
  const _PatientRegistroTab({
    required this.usuario,
    required this.registroService,
  });

  final UsuarioModel usuario;
  final RegistroService registroService;

  @override
  State<_PatientRegistroTab> createState() => _PatientRegistroTabState();
}

class _PatientRegistroTabState extends State<_PatientRegistroTab> {
  late DateTime _mesSelecionado;
  DateTime? _diaSelecionado;

  @override
  void initState() {
    super.initState();
    final hoje = DateTime.now();
    _mesSelecionado = DateTime(hoje.year, hoje.month);
    _diaSelecionado = DateTime(hoje.year, hoje.month, hoje.day);
  }

  void _trocarMes(int delta) {
    setState(() {
      _mesSelecionado = DateTime(
        _mesSelecionado.year,
        _mesSelecionado.month + delta,
      );
      final ultimoDia = DateTime(
        _mesSelecionado.year,
        _mesSelecionado.month + 1,
        0,
      ).day;
      final diaAtual = _diaSelecionado?.day ?? 1;
      final novoDia = diaAtual > ultimoDia ? ultimoDia : diaAtual;
      _diaSelecionado = DateTime(
        _mesSelecionado.year,
        _mesSelecionado.month,
        novoDia,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RegistroModel>>(
      stream: widget.registroService.observarRegistros(widget.usuario.uid),
      builder: (context, snapshot) {
        final registros = snapshot.data ?? const <RegistroModel>[];
        final diaSelecionado = _diaSelecionado;
        final registrosDoDia = diaSelecionado == null
            ? const <RegistroModel>[]
            : registros
                .where((registro) => _mesmoDia(registro.data, diaSelecionado))
                .toList();

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(usuario: widget.usuario),
                const SizedBox(height: 20),
                Text(
                  'Meus Registros',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF5D585C),
                      ),
                ),
                const SizedBox(height: 18),
                _MonthHeader(
                  mesSelecionado: _mesSelecionado,
                  onPrevious: () => _trocarMes(-1),
                  onNext: () => _trocarMes(1),
                ),
                const SizedBox(height: 12),
                _PatientCalendarGrid(
                  mesSelecionado: _mesSelecionado,
                  registros: registros,
                  diaSelecionado: _diaSelecionado,
                  onDaySelected: (date) {
                    setState(() => _diaSelecionado = date);
                  },
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        diaSelecionado == null
                            ? 'Selecione um dia'
                            : 'Registros de ${_formatarDataCompleta(diaSelecionado)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF5D585C),
                            ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => NovoRegistroScreen(
                              usuario: widget.usuario,
                              registroService: widget.registroService,
                              dataRegistro: diaSelecionado ??
                                  DateTime.now(),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8C7EEA),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Novo'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (registrosDoDia.isEmpty)
                  const _EmptyPanel(
                    text: 'Nenhum registro salvo para o dia selecionado.',
                  )
                else
                  Column(
                    children: registrosDoDia
                        .map(
                          (registro) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ProfessionalRegistroCard(registro: registro),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NovoRegistroScreen extends StatefulWidget {
  const NovoRegistroScreen({
    super.key,
    required this.usuario,
    required this.registroService,
    required this.dataRegistro,
  });

  final UsuarioModel usuario;
  final RegistroService registroService;
  final DateTime dataRegistro;

  @override
  State<NovoRegistroScreen> createState() => _NovoRegistroScreenState();
}

class _NovoRegistroScreenState extends State<NovoRegistroScreen> {
  final _relatoController = TextEditingController();

  final Map<String, int?> _emocoes = {
    'Tristeza': null,
    'Raiva': null,
    'Ansiedade': null,
    'Vergonha': null,
    'Culpa': null,
    'Alegria': null,
  };

  final Map<String, int?> _impulsos = {
    'Se machucar': null,
    'Desistir de tudo': null,
    'Usar substâncias': null,
  };

  final Map<String, bool> _medicacoesMarcadas = {};
  bool _naoTomouMedicacoes = false;
  bool? _seMachucouHoje;
  bool? _pediuAjuda;
  bool _salvando = false;

  @override
  void dispose() {
    _relatoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MedicacaoModel>>(
      stream: widget.registroService.observarMedicacoes(widget.usuario.uid),
      builder: (context, snapshot) {
        final medicacoes = snapshot.data ?? const <MedicacaoModel>[];

        for (final item in medicacoes) {
          _medicacoesMarcadas.putIfAbsent(item.nome, () => false);
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F7FB),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF8F7FB),
            elevation: 0,
            title: const Text('Novo Registro'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registro do dia ${_formatarDataCompleta(widget.dataRegistro)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5D585C),
                      ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Fez uso das medicações?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5D585C),
                      ),
                ),
                const SizedBox(height: 10),
                ...medicacoes.map((medicacao) {
                  return CheckboxListTile(
                    value: _medicacoesMarcadas[medicacao.nome] ?? false,
                    onChanged: (value) {
                      setState(() {
                        _naoTomouMedicacoes = false;
                        _medicacoesMarcadas[medicacao.nome] = value ?? false;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    title: Text(medicacao.nome),
                  );
                }),
                CheckboxListTile(
                  value: _naoTomouMedicacoes,
                  onChanged: (value) {
                    setState(() {
                      _naoTomouMedicacoes = value ?? false;
                      if (_naoTomouMedicacoes) {
                        for (final key in _medicacoesMarcadas.keys) {
                          _medicacoesMarcadas[key] = false;
                        }
                      }
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Não fiz uso das medicações'),
                ),
                if (medicacoes.isEmpty) ...[
                  Text(
                    'Cadastre ao menos uma medicação ou marque que não fez uso.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF7A7680),
                        ),
                  ),
                ],
                const SizedBox(height: 18),
                _ScaleSection(
                  title: 'Emoções',
                  subtitle:
                      'Como você se sentiu hoje? Responda em uma escala de 0 a 5.',
                  values: _emocoes,
                  onChanged: (label, value) =>
                      setState(() => _emocoes[label] = value),
                ),
                const SizedBox(height: 18),
                _ScaleSection(
                  title: 'Impulsos',
                  subtitle:
                      'Você teve algum impulso difícil de lidar? Responda em uma escala de 0 a 5.',
                  values: _impulsos,
                  onChanged: (label, value) =>
                      setState(() => _impulsos[label] = value),
                ),
                const SizedBox(height: 18),
                Text(
                  'Comportamentos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5D585C),
                      ),
                ),
                const SizedBox(height: 14),
                _BooleanQuestion(
                  question: 'Me machuquei hoje?',
                  value: _seMachucouHoje,
                  onChanged: (value) => setState(() => _seMachucouHoje = value),
                ),
                const SizedBox(height: 12),
                _BooleanQuestion(
                  question: 'Pedi ajuda quando precisei?',
                  value: _pediuAjuda,
                  onChanged: (value) => setState(() => _pediuAjuda = value),
                ),
                const SizedBox(height: 18),
                Text(
                  'Valide suas emoções, escreva sobre seu dia...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF5D585C),
                      ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _relatoController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFE7E6EA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _salvando
                        ? null
                        : () async {
                            final erro = _validarFormulario(medicacoes);
                            if (erro != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(erro)),
                              );
                              return;
                            }

                            setState(() => _salvando = true);
                            final registro = RegistroModel(
                              id: '',
                              userId: widget.usuario.uid,
                              data: DateTime(
                                widget.dataRegistro.year,
                                widget.dataRegistro.month,
                                widget.dataRegistro.day,
                                DateTime.now().hour,
                                DateTime.now().minute,
                              ),
                              corHumor: '0xFFDDF3D7',
                              medicacoesSelecionadas: _medicacoesMarcadas.entries
                                  .where((entry) => entry.value)
                                  .map((entry) => entry.key)
                                  .toList(),
                              naoTomouMedicacoes: _naoTomouMedicacoes,
                              emocoes: _emocoes.map(
                                (key, value) => MapEntry(key, value!),
                              ),
                              impulsos: _impulsos.map(
                                (key, value) => MapEntry(key, value!),
                              ),
                              seMachucouHoje: _seMachucouHoje!,
                              pediuAjuda: _pediuAjuda!,
                              relato: _relatoController.text.trim(),
                              criadoEm: DateTime.now(),
                            );

                            try {
                              await widget.registroService.salvarRegistro(registro);
                              if (mounted) {
                                Navigator.of(context).pop();
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erro: $e')),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _salvando = false);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8C7EEA),
                      foregroundColor: Colors.white,
                    ),
                    child: _salvando
                        ? const CircularProgressIndicator()
                        : const Text('Salvar registro'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _validarFormulario(List<MedicacaoModel> medicacoes) {
    final algumRemedioMarcado = _medicacoesMarcadas.values.any((item) => item);

    if (medicacoes.isNotEmpty && !_naoTomouMedicacoes && !algumRemedioMarcado) {
      return 'Selecione as medicações usadas ou marque que não fez uso.';
    }
    if (_emocoes.values.any((value) => value == null)) {
      return 'Preencha todas as emoções.';
    }
    if (_impulsos.values.any((value) => value == null)) {
      return 'Preencha todos os impulsos.';
    }
    if (_seMachucouHoje == null || _pediuAjuda == null) {
      return 'Responda todas as perguntas de comportamento.';
    }
    if (_relatoController.text.trim().isEmpty) {
      return 'Escreva sobre o seu dia antes de salvar.';
    }

    return null;
  }
}

class _MedicacaoTab extends StatefulWidget {
  const _MedicacaoTab({
    required this.usuario,
    required this.registroService,
  });

  final UsuarioModel usuario;
  final RegistroService registroService;

  @override
  State<_MedicacaoTab> createState() => _MedicacaoTabState();
}

class _MedicacaoTabState extends State<_MedicacaoTab> {
  bool _salvando = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MedicacaoModel>>(
      stream: widget.registroService.observarMedicacoes(widget.usuario.uid),
      builder: (context, snapshot) {
        final medicacoes = snapshot.data ?? const <MedicacaoModel>[];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(usuario: widget.usuario),
                const SizedBox(height: 20),
                Text(
                  'Registro de Medicações',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF5D585C),
                      ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _salvando
                      ? null
                      : () async {
                    await showDialog<void>(
                      context: context,
                      builder: (_) => _AddMedicacaoDialog(
                        onSalvar: (nome, dosagem, frequencia) async {
                          setState(() => _salvando = true);
                          try {
                            await widget.registroService.salvarMedicacao(
                              MedicacaoModel(
                                id: '',
                                userId: widget.usuario.uid,
                                nome: nome,
                                dosagem: dosagem,
                                frequencia: frequencia,
                                criadoEm: DateTime.now(),
                              ),
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Medicação salva com sucesso.'),
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _salvando = false);
                            }
                          }
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C7A7C),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _salvando ? 'Salvando...' : 'Adicionar Novo Remédio',
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Minhas Medicações',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5D585C),
                      ),
                ),
                const SizedBox(height: 14),
                if (medicacoes.isEmpty)
                  const _EmptyPanel(
                    text: 'Nenhuma medicação cadastrada ainda.',
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: medicacoes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = medicacoes[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.nome,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              if (item.dosagem.isNotEmpty) Text(item.dosagem),
                              if (item.frequencia.isNotEmpty) Text(item.frequencia),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfessionalPatientsTab extends StatelessWidget {
  const _ProfessionalPatientsTab({
    required this.usuario,
    required this.usuarioService,
    required this.registroService,
  });

  final UsuarioModel usuario;
  final UsuarioService usuarioService;
  final RegistroService registroService;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(usuario: usuario),
            const SizedBox(height: 20),
            Text(
              'Pacientes',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF5D585C),
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Selecione um paciente para ver os registros diários e as medicações cadastradas.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF7A7680),
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: FutureBuilder<List<UsuarioModel>>(
                future: usuarioService.buscarUsuariosPorIds(
                  usuario.pacientesVinculados,
                ),
                builder: (context, snapshot) {
                  final pacientes = snapshot.data ?? const <UsuarioModel>[];

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (pacientes.isEmpty) {
                    return const _EmptyPanel(
                      text: 'Nenhum paciente conectado ainda.',
                    );
                  }

                  return ListView.separated(
                    itemCount: pacientes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final paciente = pacientes[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _ProfessionalPatientDetailScreen(
                                paciente: paciente,
                                registroService: registroService,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              _AvatarCircle(
                                fotoPerfil: paciente.fotoPerfil,
                                size: 48,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      paciente.nome,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF5D585C),
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Código: ${paciente.codigo}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: const Color(0xFF7A7680),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF8C7EEA),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab({
    required this.usuario,
    required this.onPerfilAtualizado,
    required this.onSair,
    required this.onExcluirConta,
    required this.usuarioService,
  });

  final UsuarioModel usuario;
  final ValueChanged<UsuarioModel> onPerfilAtualizado;
  final Future<void> Function() onSair;
  final Future<void> Function() onExcluirConta;
  final UsuarioService usuarioService;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(usuario: usuario),
            const SizedBox(height: 18),
            _SettingsOption(
              label: 'Meu Perfil',
              onTap: () async {
                final atualizado = await Navigator.of(context).push<UsuarioModel>(
                  MaterialPageRoute(
                    builder: (_) => _ProfileScreen(
                      usuario: usuario,
                      usuarioService: usuarioService,
                      onExcluirConta: onExcluirConta,
                    ),
                  ),
                );
                if (atualizado != null) {
                  onPerfilAtualizado(atualizado);
                }
              },
            ),
            _SettingsOption(
              label: 'Conectar',
              helperText: usuario.tipo == TipoUsuario.profissional
                  ? 'Use o código do paciente para acessar os registros dele.'
                  : 'Compartilhe seu código único com profissionais.',
              onTap: () async {
                final atualizado = await Navigator.of(context).push<UsuarioModel>(
                  MaterialPageRoute(
                    builder: (_) => _ConnectScreen(
                      usuario: usuario,
                      usuarioService: usuarioService,
                    ),
                  ),
                );
                if (atualizado != null) {
                  onPerfilAtualizado(atualizado);
                }
              },
            ),
            _SettingsOption(
              label: 'Dúvidas',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _FaqScreen(tipoUsuario: usuario.tipo),
                  ),
                );
              },
            ),
            _SettingsOption(
              label: 'Sair',
              showDivider: false,
              onTap: onSair,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfessionalPatientDetailScreen extends StatefulWidget {
  const _ProfessionalPatientDetailScreen({
    required this.paciente,
    required this.registroService,
  });

  final UsuarioModel paciente;
  final RegistroService registroService;

  @override
  State<_ProfessionalPatientDetailScreen> createState() =>
      _ProfessionalPatientDetailScreenState();
}

class _ProfessionalPatientDetailScreenState
    extends State<_ProfessionalPatientDetailScreen> {
  DateTime _dataSelecionada = DateTime.now();

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (data != null) {
      setState(() => _dataSelecionada = data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7FB),
        elevation: 0,
        title: Text(widget.paciente.nome),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(usuario: widget.paciente, showAvatar: false),
              const SizedBox(height: 20),
              Text(
                'Registros diários',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF5D585C),
                    ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _selecionarData,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        color: Color(0xFF8C7EEA),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Data selecionada: ${_formatarDataCompleta(_dataSelecionada)}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF5D585C),
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<List<RegistroModel>>(
                  stream: widget.registroService
                      .observarRegistros(widget.paciente.uid),
                  builder: (context, snapshot) {
                    final registros = snapshot.data ?? const <RegistroModel>[];
                    final registrosDoDia = registros
                        .where((registro) => _mesmoDia(registro.data, _dataSelecionada))
                        .toList();

                    return ListView(
                      children: [
                        if (registrosDoDia.isEmpty)
                          const _EmptyPanel(
                            text:
                                'Não há registros salvos para a data selecionada.',
                          )
                        else
                          ...registrosDoDia.map(
                            (registro) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ProfessionalRegistroCard(
                                registro: registro,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          'Medicações cadastradas',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF5D585C),
                                  ),
                        ),
                        const SizedBox(height: 12),
                        StreamBuilder<List<MedicacaoModel>>(
                          stream: widget.registroService
                              .observarMedicacoes(widget.paciente.uid),
                          builder: (context, medSnapshot) {
                            final medicacoes =
                                medSnapshot.data ?? const <MedicacaoModel>[];

                            if (medicacoes.isEmpty) {
                              return const _EmptyPanel(
                                text: 'Esse paciente ainda não cadastrou medicações.',
                              );
                            }

                            return Column(
                              children: medicacoes.map((medicacao) {
                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        medicacao.nome,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF5D585C),
                                            ),
                                      ),
                                      if (medicacao.dosagem.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text('Dosagem: ${medicacao.dosagem}'),
                                      ],
                                      if (medicacao.frequencia.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text('Frequência: ${medicacao.frequencia}'),
                                      ],
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileScreen extends StatefulWidget {
  const _ProfileScreen({
    required this.usuario,
    required this.usuarioService,
    required this.onExcluirConta,
  });

  final UsuarioModel usuario;
  final UsuarioService usuarioService;
  final Future<void> Function() onExcluirConta;

  @override
  State<_ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<_ProfileScreen> {
  final _picker = ImagePicker();
  late UsuarioModel _usuario;
  bool _processando = false;

  @override
  void initState() {
    super.initState();
    _usuario = widget.usuario;
  }

  Future<void> _editarNome() async {
    final controller = TextEditingController(text: _usuario.nome);
    final novoNome = await _showTextEditDialog(
      title: 'Editar nome',
      controller: controller,
      keyboardType: TextInputType.name,
    );
    if (novoNome == null) return;

    await _atualizarPerfil(nome: novoNome);
  }

  Future<void> _editarEmail() async {
    final controller = TextEditingController(text: _usuario.email);
    final novoEmail = await _showTextEditDialog(
      title: 'Mudar email',
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      helper:
          'Ao salvar, um email de verificação será enviado para confirmar a troca.',
    );
    if (novoEmail == null) return;

    await _atualizarPerfil(email: novoEmail);
  }

  Future<void> _editarSenha() async {
    final controller = TextEditingController();
    final novaSenha = await _showTextEditDialog(
      title: 'Mudar senha',
      controller: controller,
      obscureText: true,
      helper: 'Digite a nova senha com pelo menos 6 caracteres.',
    );
    if (novaSenha == null) return;

    await _runAction(() async {
      await widget.usuarioService.alterarSenha(novaSenha: novaSenha);
      _showMessage('Senha atualizada com sucesso.');
    });
  }

  Future<void> _editarFoto() async {
    final imagem = await _picker.pickImage(source: ImageSource.gallery);
    if (imagem == null) return;

    await _atualizarPerfil(fotoPerfil: imagem.path);
  }

  Future<void> _atualizarPerfil({
    String? nome,
    String? email,
    String? fotoPerfil,
  }) async {
    await _runAction(() async {
      final atualizado = await widget.usuarioService.atualizarPerfil(
        usuario: _usuario,
        nome: nome,
        email: email,
        fotoPerfil: fotoPerfil,
      );
      if (!mounted) return;
      setState(() => _usuario = atualizado);
      _showMessage('Dados atualizados com sucesso.');
    });
  }

  Future<void> _confirmarExclusao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir conta'),
          content: const Text(
            'Essa ação é permanente. Deseja realmente excluir sua conta?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    await _runAction(() async {
      await widget.onExcluirConta();
    });
  }

  Future<String?> _showTextEditDialog({
    required String title,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? helper,
  }) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (helper != null) ...[
                Text(helper),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _runAction(Future<void> Function() action) async {
    if (_processando) return;
    setState(() => _processando = true);
    try {
      await action();
    } catch (e) {
      _showMessage('Erro: $e');
    } finally {
      if (mounted) {
        setState(() => _processando = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_usuario);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F7FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F7FB),
          elevation: 0,
          title: const Text('Meu Perfil'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(_usuario),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(usuario: _usuario, showAvatar: false),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AvatarCircle(
                    fotoPerfil: _usuario.fotoPerfil,
                    size: 88,
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, ${_usuario.nome}',
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF68636B),
                                  ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _processando ? null : _editarFoto,
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Editar foto'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE0DDE4),
                            foregroundColor: const Color(0xFF6A6670),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _SettingsOption(label: 'Editar nome', onTap: _editarNome),
              _SettingsOption(label: 'Mudar Email', onTap: _editarEmail),
              _SettingsOption(label: 'Mudar Senha', onTap: _editarSenha),
              _SettingsOption(
                label: 'Excluir Conta',
                showDivider: false,
                onTap: _confirmarExclusao,
              ),
              if (_usuario.tipo == TipoUsuario.paciente) ...[
                const SizedBox(height: 28),
                Text(
                  'Meu código',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF66616A),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD8EEF7), Color(0xFFE7F6FD)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _usuario.codigo,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: const Color(0xFF35505F),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.6,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Esse é o código único que o profissional usa para se conectar à sua conta e acessar seus registros.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF58707D),
                              height: 1.45,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectScreen extends StatefulWidget {
  const _ConnectScreen({
    required this.usuario,
    required this.usuarioService,
  });

  final UsuarioModel usuario;
  final UsuarioService usuarioService;

  @override
  State<_ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<_ConnectScreen> {
  final _codigoController = TextEditingController();
  late UsuarioModel _usuario;
  bool _processando = false;

  @override
  void initState() {
    super.initState();
    _usuario = widget.usuario;
  }

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _adicionarPaciente() async {
    final codigo = _codigoController.text.trim().toUpperCase();
    if (codigo.isEmpty) {
      _showMessage('Digite o código do paciente.');
      return;
    }

    setState(() => _processando = true);
    try {
      final paciente = await widget.usuarioService.buscarPorCodigo(codigo);
      if (paciente == null) {
        throw Exception('Nenhum paciente encontrado com esse código.');
      }
      if (paciente.uid == _usuario.uid) {
        throw Exception('Você não pode se conectar ao próprio perfil.');
      }

      await widget.usuarioService.vincularPacienteAoProfissional(
        pacienteId: paciente.uid,
        profissionalId: _usuario.uid,
      );

      final atualizado = await widget.usuarioService.buscarUsuario(_usuario.uid);
      if (atualizado != null && mounted) {
        setState(() {
          _usuario = atualizado;
          _codigoController.clear();
        });
      }
      _showMessage('Paciente conectado com sucesso.');
    } catch (e) {
      _showMessage('Erro: $e');
    } finally {
      if (mounted) {
        setState(() => _processando = false);
      }
    }
  }

  Future<void> _removerPaciente(UsuarioModel paciente) async {
    setState(() => _processando = true);
    try {
      await widget.usuarioService.desvincularPacienteDoProfissional(
        pacienteId: paciente.uid,
        profissionalId: _usuario.uid,
      );
      final atualizado = await widget.usuarioService.buscarUsuario(_usuario.uid);
      if (atualizado != null && mounted) {
        setState(() => _usuario = atualizado);
      }
      _showMessage('Paciente removido da sua lista.');
    } catch (e) {
      _showMessage('Erro: $e');
    } finally {
      if (mounted) {
        setState(() => _processando = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_usuario);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F7FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F7FB),
          elevation: 0,
          title: const Text('Conectar'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(_usuario),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
          child: _usuario.tipo == TipoUsuario.paciente
              ? _PatientConnectContent(usuario: _usuario)
              : _ProfessionalConnectContent(
                  usuario: _usuario,
                  codigoController: _codigoController,
                  processando: _processando,
                  usuarioService: widget.usuarioService,
                  onAdicionarPaciente: _adicionarPaciente,
                  onRemoverPaciente: _removerPaciente,
                ),
        ),
      ),
    );
  }
}

class _ProfessionalRegistroCard extends StatelessWidget {
  const _ProfessionalRegistroCard({required this.registro});

  final RegistroModel registro;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: _parseColor(registro.corHumor),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _formatarDataHora(registro.data),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5D585C),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoBlock(
            title: 'Medicações usadas',
            content: registro.naoTomouMedicacoes
                ? 'Paciente informou que não fez uso das medicações.'
                : (registro.medicacoesSelecionadas.isEmpty
                    ? 'Nenhuma medicação marcada.'
                    : registro.medicacoesSelecionadas.join(', ')),
          ),
          const SizedBox(height: 12),
          _InfoBlock(
            title: 'Emoções',
            content: _formatarMapaEscala(registro.emocoes),
          ),
          const SizedBox(height: 12),
          _InfoBlock(
            title: 'Impulsos',
            content: _formatarMapaEscala(registro.impulsos),
          ),
          const SizedBox(height: 12),
          _InfoBlock(
            title: 'Comportamentos',
            content:
                'Se machucou: ${registro.seMachucouHoje ? 'Sim' : 'Não'}\nPediu ajuda: ${registro.pediuAjuda ? 'Sim' : 'Não'}',
          ),
          if (registro.relato.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoBlock(
              title: 'Relato do dia',
              content: registro.relato,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5D585C),
              ),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6F6A73),
                height: 1.5,
              ),
        ),
      ],
    );
  }
}

class _PatientConnectContent extends StatelessWidget {
  const _PatientConnectContent({required this.usuario});

  final UsuarioModel usuario;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TopBar(usuario: usuario, showAvatar: false),
        const SizedBox(height: 24),
        Text(
          'Seu código de conexão',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF66616A),
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD8EEF7), Color(0xFFEAF8FF)],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            usuario.codigo,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF35505F),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Peça para seu profissional, como psicólogo ou psiquiatra, baixar o app e inserir este código na área de conexões dele. Assim ele poderá se conectar com você e acompanhar seus registros.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF6F6A73),
                height: 1.55,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Compartilhe esse código somente com o profissional que vai te acompanhar.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF7A7680),
                ),
          ),
        ),
      ],
    );
  }
}

class _ProfessionalConnectContent extends StatelessWidget {
  const _ProfessionalConnectContent({
    required this.usuario,
    required this.codigoController,
    required this.processando,
    required this.usuarioService,
    required this.onAdicionarPaciente,
    required this.onRemoverPaciente,
  });

  final UsuarioModel usuario;
  final TextEditingController codigoController;
  final bool processando;
  final UsuarioService usuarioService;
  final Future<void> Function() onAdicionarPaciente;
  final Future<void> Function(UsuarioModel paciente) onRemoverPaciente;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TopBar(usuario: usuario, showAvatar: false),
        const SizedBox(height: 18),
        Text(
          'Adicionar novo paciente',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF66616A),
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Digite o código que o paciente te enviou para conectar a conta dele ao seu perfil.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF6F6A73),
                height: 1.55,
              ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: codigoController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'Código do paciente',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: processando ? null : onAdicionarPaciente,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8C7EEA),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Conectar paciente'),
          ),
        ),
        const SizedBox(height: 26),
        Text(
          'Pacientes conectados',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF66616A),
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: FutureBuilder<List<UsuarioModel>>(
            future: usuarioService.buscarUsuariosPorIds(usuario.pacientesVinculados),
            builder: (context, snapshot) {
              final pacientes = snapshot.data ?? const <UsuarioModel>[];
              if (pacientes.isEmpty) {
                return const _EmptyPanel(
                  text: 'Você ainda não conectou nenhum paciente.',
                );
              }

              return ListView.separated(
                itemCount: pacientes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final paciente = pacientes[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                paciente.nome,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Código: ${paciente.codigo}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: const Color(0xFF7A7680)),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: processando
                              ? null
                              : () => onRemoverPaciente(paciente),
                          child: const Text('Remover'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FaqScreen extends StatelessWidget {
  const _FaqScreen({required this.tipoUsuario});

  final TipoUsuario tipoUsuario;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7FB),
        elevation: 0,
        title: const Text('Dúvidas'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TopBar(showAvatar: false),
            const SizedBox(height: 24),
            Text(
              tipoUsuario == TipoUsuario.paciente
                  ? 'Como funciona o compartilhamento?'
                  : 'Como funciona a conexão com pacientes?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF66616A),
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 14),
            Text(
              tipoUsuario == TipoUsuario.paciente
                  ? 'Para compartilhar seus registros com um profissional, você precisa enviar seu código de conexão para ele. Depois que esse profissional inserir seu código na área de conexões dele, a conta dele ficará vinculada à sua.'
                  : 'Para acessar os registros de um paciente, ele precisa te enviar o código único dele. Depois que você inserir esse código na área de conexões, a conta do paciente ficará vinculada ao seu perfil.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF6F6A73),
                    height: 1.55,
                  ),
            ),
            const SizedBox(height: 18),
            Text(
              tipoUsuario == TipoUsuario.paciente
                  ? 'Quem pode ver meus registros?'
                  : 'O que eu consigo ver do paciente?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF66616A),
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              tipoUsuario == TipoUsuario.paciente
                  ? 'Somente o profissional conectado à sua conta pode acessar o calendário e as informações que você preenche nos registros. Essas informações não ficam liberadas para outras pessoas.'
                  : 'Somente você, como profissional conectado à conta do paciente, pode acessar o calendário e as informações que ele preenche nos registros. Outros profissionais só terão acesso se o paciente também compartilhar o código com eles.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF6F6A73),
                    height: 1.55,
                  ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
                child: Text(
                tipoUsuario == TipoUsuario.paciente
                    ? 'Se você não quiser mais compartilhar seus registros, a conexão com o profissional pode ser removida depois.'
                    : 'Se o acompanhamento terminar, você pode remover o paciente da sua lista de conexões a qualquer momento.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF7A7680),
                      height: 1.5,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    this.usuario,
    this.onAvatarTap,
    this.showAvatar = true,
  });

  final UsuarioModel? usuario;
  final VoidCallback? onAvatarTap;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'LumiSpace - Diário TPB',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF9A98A0),
                ),
          ),
        ),
        if (showAvatar)
          GestureDetector(
            onTap: onAvatarTap,
            child: _AvatarCircle(
              fotoPerfil: usuario?.fotoPerfil,
              size: 36,
            ),
          ),
      ],
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.fotoPerfil,
    required this.size,
  });

  final String? fotoPerfil;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        fotoPerfil != null && fotoPerfil!.isNotEmpty && File(fotoPerfil!).existsSync();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        shape: BoxShape.circle,
        image: hasPhoto
            ? DecorationImage(
                image: FileImage(File(fotoPerfil!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasPhoto
          ? null
          : Icon(
              Icons.person,
              color: Colors.white.withValues(alpha: 0.85),
              size: size * 0.45,
            ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({required this.registros});

  final List<RegistroModel> registros;

  @override
  Widget build(BuildContext context) {
    final monthDays = List.generate(30, (index) => index + 1);
    final map = <int, Color>{};
    for (final registro in registros) {
      map[registro.data.day] = _parseColor(registro.corHumor);
    }

    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('SUN'),
            Text('MON'),
            Text('TUE'),
            Text('WED'),
            Text('THU'),
            Text('FRI'),
            Text('SAT'),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 8,
          children: monthDays.map((day) {
            final color = map[day];
            return Container(
              width: 39,
              height: 28,
              decoration: BoxDecoration(
                color: color ?? const Color(0xFFF0EFF3),
                borderRadius: BorderRadius.circular(8),
                border: day == DateTime.now().day
                    ? Border.all(color: const Color(0xFF8C7EEA), width: 2)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text('$day'),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.mesSelecionado,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime mesSelecionado;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Text(
            _formatarMesAno(mesSelecionado),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF5D585C),
                ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _PatientCalendarGrid extends StatelessWidget {
  const _PatientCalendarGrid({
    required this.mesSelecionado,
    required this.registros,
    required this.diaSelecionado,
    required this.onDaySelected,
  });

  final DateTime mesSelecionado;
  final List<RegistroModel> registros;
  final DateTime? diaSelecionado;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final primeiroDia = DateTime(mesSelecionado.year, mesSelecionado.month, 1);
    final ultimoDia = DateTime(mesSelecionado.year, mesSelecionado.month + 1, 0);
    final offset = primeiroDia.weekday % 7;
    final totalSlots = offset + ultimoDia.day;
    final totalCells = totalSlots % 7 == 0 ? totalSlots : totalSlots + (7 - totalSlots % 7);
    final registrosPorDia = <int, int>{};

    for (final registro in registros) {
      if (registro.data.year == mesSelecionado.year &&
          registro.data.month == mesSelecionado.month) {
        registrosPorDia.update(registro.data.day, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    const weekDays = ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekDays
              .map(
                (day) => Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF8A8590),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalCells,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final dayNumber = index - offset + 1;
            final isValidDay = dayNumber > 0 && dayNumber <= ultimoDia.day;
            if (!isValidDay) {
              return const SizedBox.shrink();
            }

            final date = DateTime(mesSelecionado.year, mesSelecionado.month, dayNumber);
            final selected = diaSelecionado != null && _mesmoDia(date, diaSelecionado!);
            final totalRegistros = registrosPorDia[dayNumber] ?? 0;

            return InkWell(
              onTap: () => onDaySelected(date),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFD9D1FB) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF8C7EEA)
                        : const Color(0xFFE7E3EF),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$dayNumber',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF5D585C),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalRegistros == 0
                          ? 'Sem registros'
                          : '$totalRegistros registro${totalRegistros > 1 ? 's' : ''}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF7A7680),
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ScaleSection extends StatelessWidget {
  const _ScaleSection({
    required this.title,
    required this.subtitle,
    required this.values,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final Map<String, int?> values;
  final void Function(String label, int value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5D585C),
              ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF5D585C),
                height: 1.45,
              ),
        ),
        const SizedBox(height: 12),
        ...values.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    entry.key,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF6E6971),
                        ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6E5E8),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(6, (index) {
                        final selected = entry.value == index;
                        return GestureDetector(
                          onTap: () => onChanged(entry.key, index),
                          child: Text(
                            '$index',
                            style: TextStyle(
                              color: selected
                                  ? const Color(0xFF8C7EEA)
                                  : const Color(0xFF6E6971),
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _BooleanQuestion extends StatelessWidget {
  const _BooleanQuestion({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  final String question;
  final bool? value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF5D585C),
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE6E5E8),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              _BooleanOption(
                label: 'Sim',
                selected: value == true,
                onTap: () => onChanged(true),
              ),
              _BooleanOption(
                label: 'Não',
                selected: value == false,
                onTap: () => onChanged(false),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BooleanOption extends StatelessWidget {
  const _BooleanOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(label),
        ),
      ),
    );
  }
}

class _AddMedicacaoDialog extends StatefulWidget {
  const _AddMedicacaoDialog({required this.onSalvar});

  final Future<void> Function(String nome, String dosagem, String frequencia)
      onSalvar;

  @override
  State<_AddMedicacaoDialog> createState() => _AddMedicacaoDialogState();
}

class _AddMedicacaoDialogState extends State<_AddMedicacaoDialog> {
  final _nomeController = TextEditingController();
  final _dosagemController = TextEditingController();
  final _frequenciaController = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _dosagemController.dispose();
    _frequenciaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova medicação'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nomeController,
            decoration: const InputDecoration(labelText: 'Nome'),
          ),
          TextField(
            controller: _dosagemController,
            decoration: const InputDecoration(labelText: 'Dosagem'),
          ),
          TextField(
            controller: _frequenciaController,
            decoration: const InputDecoration(labelText: 'Frequência'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _enviando
              ? null
              : () async {
                  final nome = _nomeController.text.trim();
                  final dosagem = _dosagemController.text.trim();
                  final frequencia = _frequenciaController.text.trim();

                  if (nome.isEmpty || dosagem.isEmpty || frequencia.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Preencha nome, dosagem e frequência da medicação.',
                        ),
                      ),
                    );
                    return;
                  }

                  setState(() => _enviando = true);
                  try {
                    await widget.onSalvar(nome, dosagem, frequencia);
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro: $e')),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _enviando = false);
                    }
                  }
                },
          child: Text(_enviando ? 'Salvando...' : 'Salvar'),
        ),
      ],
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.data});

  final _HomeCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: data.color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4D4A51),
                  height: 1.25,
                ),
          ),
          const Spacer(),
          Text(
            data.subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF7A7680),
                ),
          ),
        ],
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(label),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF7A7680),
            ),
      ),
    );
  }
}

class _SettingsOption extends StatelessWidget {
  const _SettingsOption({
    required this.label,
    this.helperText,
    this.onTap,
    this.showDivider = true,
  });

  final String label;
  final String? helperText;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF69646B),
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (helperText != null) ...[
              const SizedBox(height: 6),
              Text(
                helperText!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8A8590),
                    ),
              ),
            ],
            if (showDivider) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFE2DDE8)),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF8C7EEA);
    final inactiveColor = const Color(0xFF9996A1);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: selected ? activeColor : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                selected ? activeIcon : icon,
                size: 16,
                color: selected ? Colors.white : inactiveColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected ? activeColor : inactiveColor,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavConfig {
  const _NavConfig(this.label, this.icon, this.activeIcon);

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class _HomeCardData {
  const _HomeCardData({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Color color;
}

class _MoodOption {
  const _MoodOption(this.label, this.color);

  final String label;
  final Color color;
}

Color _parseColor(String raw) {
  return Color(int.tryParse(raw) ?? 0xFFDDF3D7);
}

String _dateLabel(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month';
}

String _formatarDataCompleta(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String _formatarMesAno(DateTime date) {
  const meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  return '${meses[date.month - 1]} ${date.year}';
}

String _formatarDataHora(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/${date.year} às $hour:$minute';
}

bool _mesmoDia(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatarMapaEscala(Map<String, int> valores) {
  if (valores.isEmpty) {
    return 'Nenhuma informação registrada.';
  }

  return valores.entries.map((entry) => '${entry.key}: ${entry.value}').join('\n');
}
