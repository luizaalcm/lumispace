import 'package:flutter/material.dart';

import '../../models/usuario_model.dart';
import '../home/home_screen.dart';
import '../../services/usuario_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = UsuarioService();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _registroController = TextEditingController();
  final _especialidadeController = TextEditingController();

  bool _modoCadastro = false;
  bool _carregando = false;
  TipoUsuario _tipoSelecionado = TipoUsuario.paciente;
  ConselhoProfissional _conselhoSelecionado = ConselhoProfissional.crp;
  DateTime? _dataNascimento;

  bool get _isProfissional => _tipoSelecionado == TipoUsuario.profissional;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _registroController.dispose();
    _especialidadeController.dispose();
    super.dispose();
  }

  Future<void> _selecionarDataNascimento() async {
    final agora = DateTime.now();
    final dataInicial = _dataNascimento ?? DateTime(2000, 1, 1);
    final data = await showDatePicker(
      context: context,
      initialDate: dataInicial,
      firstDate: DateTime(1900),
      lastDate: DateTime(agora.year, agora.month, agora.day),
    );

    if (data != null) {
      setState(() => _dataNascimento = data);
    }
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  void _alternarTipo(TipoUsuario tipo) {
    setState(() {
      _tipoSelecionado = tipo;
      if (!_isProfissional) {
        _registroController.clear();
        _especialidadeController.clear();
        _conselhoSelecionado = ConselhoProfissional.crp;
      }
    });
  }

  Future<void> _submeter() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    if (_modoCadastro && _dataNascimento == null) {
      _mostrarMensagem('Selecione a data de nascimento.');
      return;
    }

    setState(() => _carregando = true);

    try {
      if (_modoCadastro) {
        final usuario = await _service.criarUsuario(
          nome: _nomeController.text.trim(),
          email: _emailController.text.trim(),
          senha: _senhaController.text.trim(),
          tipo: _tipoSelecionado,
          dataNascimento: _dataNascimento!,
          conselhoProfissional:
              _isProfissional ? _conselhoSelecionado : null,
          registroProfissional:
              _isProfissional ? _registroController.text.trim() : null,
          especialidade:
              _isProfissional ? _especialidadeController.text.trim() : null,
        );

        _mostrarMensagem('Cadastro realizado com sucesso!');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => HomeScreen(usuario: usuario),
            ),
          );
        }
      } else {
        final usuario = await _service.fazerLogin(
          email: _emailController.text.trim(),
          senha: _senhaController.text.trim(),
          tipoEsperado: _tipoSelecionado,
        );

        _mostrarMensagem('Bem-vindo, ${usuario.nome}');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => HomeScreen(usuario: usuario),
            ),
          );
        }
      }
    } catch (e) {
      _mostrarMensagem('Erro: $e');
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  Future<void> _redefinirSenha() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _mostrarMensagem('Informe seu email para redefinir a senha.');
      return;
    }

    if (!email.contains('@')) {
      _mostrarMensagem('Informe um email valido.');
      return;
    }

    try {
      await _service.enviarRedefinicaoSenha(email);
      _mostrarMensagem('Enviamos um link para redefinir sua senha por email.');
    } catch (e) {
      _mostrarMensagem('Erro: $e');
    }
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  String? _validarNome(String? value) {
    if (!_modoCadastro) return null;
    if (value == null || value.trim().isEmpty) {
      return 'Informe seu nome.';
    }
    return null;
  }

  String? _validarEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Informe seu email.';
    if (!email.contains('@')) return 'Informe um email valido.';
    return null;
  }

  String? _validarSenha(String? value) {
    final senha = value?.trim() ?? '';
    if (senha.isEmpty) return 'Informe sua senha.';
    if (_modoCadastro && senha.length < 6) {
      return 'A senha precisa ter ao menos 6 caracteres.';
    }
    return null;
  }

  String? _validarRegistro(String? value) {
    if (!_modoCadastro || !_isProfissional) return null;
    if ((value ?? '').trim().isEmpty) {
      return 'Informe seu ${_conselhoSelecionado.name.toUpperCase()}.';
    }
    return null;
  }

  String? _validarEspecialidade(String? value) {
    if (!_modoCadastro || !_isProfissional) return null;
    if ((value ?? '').trim().isEmpty) {
      return 'Informe sua especialidade.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F2FF),
      body: Stack(
        children: [
          Positioned(
            top: -90,
            right: -30,
            child: _AuthBubble(
              size: 220,
              color: const Color(0x66E9D7FF),
            ),
          ),
          Positioned(
            top: 180,
            left: -60,
            child: _AuthBubble(
              size: 180,
              color: const Color(0x4DF9D9EB),
            ),
          ),
          Positioned(
            bottom: -70,
            right: -20,
            child: _AuthBubble(
              size: 190,
              color: const Color(0x40D9CCFF),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 56,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Form(
                          key: _formKey,
                          child: Container(
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: const Color(0xFFE9DDF8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB59BEA).withValues(alpha: 0.14),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                          Text(
                            'LumiSpace - Diário TPB',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: const Color(0xFF8F86A0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              _modoCadastro ? 'Criar conta' : 'Fazer login',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF564F63),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              _modoCadastro
                                  ? 'Monte seu espacinho com calma para comecar.'
                                  : 'Que bom te ver por aqui de novo.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF857C92),
                                height: 1.45,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _ModoToggle(
                            isCadastro: _modoCadastro,
                            onChanged: (value) {
                              setState(() => _modoCadastro = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          _PerfilToggle(
                            tipoSelecionado: _tipoSelecionado,
                            onChanged: _alternarTipo,
                          ),
                          const SizedBox(height: 20),
                          if (_modoCadastro) ...[
                            _CampoArredondado(
                              controller: _nomeController,
                              label: 'Nome',
                              validator: _validarNome,
                            ),
                            const SizedBox(height: 12),
                          ],
                          _CampoArredondado(
                            controller: _emailController,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: _validarEmail,
                          ),
                          const SizedBox(height: 12),
                          if (_modoCadastro) ...[
                            _DateField(
                              label: 'Data de nascimento',
                              value: _dataNascimento == null
                                  ? null
                                  : _formatarData(_dataNascimento!),
                              onTap: _selecionarDataNascimento,
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (_modoCadastro && _isProfissional) ...[
                            Text(
                              'Registro profissional',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: const Color(0xFF5A5557),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _ConselhoChip(
                                    label: 'CRP',
                                    selected: _conselhoSelecionado ==
                                        ConselhoProfissional.crp,
                                    onTap: () => setState(
                                      () => _conselhoSelecionado =
                                          ConselhoProfissional.crp,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _ConselhoChip(
                                    label: 'CRM',
                                    selected: _conselhoSelecionado ==
                                        ConselhoProfissional.crm,
                                    onTap: () => setState(
                                      () => _conselhoSelecionado =
                                          ConselhoProfissional.crm,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _CampoArredondado(
                              controller: _registroController,
                              label: _conselhoSelecionado ==
                                      ConselhoProfissional.crp
                                  ? 'Numero do CRP'
                                  : 'Numero do CRM',
                              validator: _validarRegistro,
                            ),
                            const SizedBox(height: 12),
                            _CampoArredondado(
                              controller: _especialidadeController,
                              label: 'Especialidade',
                              validator: _validarEspecialidade,
                            ),
                            const SizedBox(height: 12),
                          ],
                          _CampoArredondado(
                            controller: _senhaController,
                            label: 'Senha',
                            obscureText: true,
                            validator: _validarSenha,
                          ),
                                if (!_modoCadastro) ...[
                                  const SizedBox(height: 10),
                                  Center(
                                    child: TextButton(
                                      onPressed:
                                          _carregando ? null : _redefinirSenha,
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFF8A7FF0),
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: const Text('Esqueceu a Senha?'),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                              onPressed: _carregando ? null : _submeter,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD8CCFA),
                                foregroundColor: const Color(0xFF4F4772),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                              ),
                                    child: _carregando
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            _modoCadastro
                                                ? 'Vamos comecar!'
                                                : 'Entrar',
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Pacientes podem ter varios profissionais vinculados, e cada profissional pode acompanhar varios pacientes.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF7C7679),
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CampoArredondado extends StatelessWidget {
  const _CampoArredondado({
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFFFFDFF),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFEADFF8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF8A7FF0), width: 1.4),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFFFFDFF),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFEADFF8)),
          ),
        ),
        child: Text(
          value ?? 'Selecionar data',
          style: TextStyle(
            color: value == null ? const Color(0xFF918A8E) : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _ModoToggle extends StatelessWidget {
  const _ModoToggle({
    required this.isCadastro,
    required this.onChanged,
  });

  final bool isCadastro;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAE6F2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Login',
              selected: !isCadastro,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: 'Criar conta',
              selected: isCadastro,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerfilToggle extends StatelessWidget {
  const _PerfilToggle({
    required this.tipoSelecionado,
    required this.onChanged,
  });

  final TipoUsuario tipoSelecionado;
  final ValueChanged<TipoUsuario> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ToggleButton(
            label: 'Paciente',
            selected: tipoSelecionado == TipoUsuario.paciente,
            onTap: () => onChanged(TipoUsuario.paciente),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ToggleButton(
            label: 'Profissional',
            selected: tipoSelecionado == TipoUsuario.profissional,
            onTap: () => onChanged(TipoUsuario.profissional),
          ),
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected
                ? const Color(0xFF534D6B)
                : const Color(0xFF7D7686),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ConselhoChip extends StatelessWidget {
  const _ConselhoChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFD9D1FB) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected
                ? const Color(0xFF4F4772)
                : const Color(0xFF756E79),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AuthBubble extends StatelessWidget {
  const _AuthBubble({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 40,
              spreadRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}
