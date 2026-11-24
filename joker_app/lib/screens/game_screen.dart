import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
// =========================================================================
// ECRÃ PRINCIPAL DO JOGO (GAME SCREEN)
// =========================================================================
// Responsável por renderizar a interface ativa da partida, controlar a
// interação do utilizador com as perguntas/respostas, e orquestrar a
// ativação e seleção dos Jokers.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // =========================================================================
  // 1. INICIALIZAÇÃO E CONTROLO DE ESTADO LOCAL
  // =========================================================================

  // Modo de seleção ativo para o Joker Standard (permite escolher duas opções da UI)
  bool _jokerSelectionMode = false;

  // Guarda os índices (0 a 3) das duas opções selecionadas pelo utilizador para o Joker
  final List<int> _selectedForJoker = [];

  // INICIALIZAÇÃO DE FLUXO (Defesa):
  // Dispara o início do jogo assim que o frame da UI estiver totalmente renderizado,
  // garantindo que não há conflitos no ciclo de vida do Provider/Widget.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(context, listen: false).startGame();
    });
  }

  // =========================================================================
  // 2. CONSTRUTOR DE BOTÃO DE RESPOSTA (BUILDER AUXILIAR)
  // =========================================================================
  
  // COMPORTAMENTO DA UI (Defesa):
  // 1. Oculta opções eliminadas pelo Joker mantendo o espaço ocupado na árvore de widgets 
  //    (maintainSize/maintainAnimation/maintainState) para evitar que o layout "salte".
  // 2. Interceta o clique: se estiver em modo Joker, adiciona/remove do conjunto de seleção.
  //    Se for resposta direta, submete-a ao GameProvider e reinicia o estado local.
  Widget _buildAnswerButton(GameProvider game, List<dynamic> options, int index, String label) {
    if (index >= options.length) return const SizedBox.shrink();
    
    final optionText = options[index].toString();
    final isEliminated = game.eliminatedOptions.contains(optionText);
    final isSelected = _selectedForJoker.contains(index);

    return Visibility(
      visible: !isEliminated,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: AnswerButton(
        label: label,
        text: optionText,
        isSelected: isSelected,
        isSelectionMode: _jokerSelectionMode,
        onPressed: () {
          if (_jokerSelectionMode) {
            setState(() {
              if (_selectedForJoker.contains(index)) {
                _selectedForJoker.remove(index);
              } else if (_selectedForJoker.length < 2) {
                _selectedForJoker.add(index);
              }
            });
          } else {
            // COMPORTAMENTO: Submissão normal e limpeza preventiva de estado local do Joker
            setState(() {
              _jokerSelectionMode = false;
              _selectedForJoker.clear();
            });
            game.submitAnswer(index);
          }
        },
      ),
    );
  }
  // =========================================================================
  // 3. ESTRUTURA PRINCIPAL DO ECRÃ (MÉTODO BUILD)
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    // REGRA DE NEGÓCIO (Ronda Bónus):
    // A Ronda Bónus é ativada dinamicamente pelo provider após a 4ª e 8ª pergunta normal.
    final bool isInBonusRound = game.isBonusRoundActive;

    // VALIDAÇÃO DE REGRA (Secção 3.6 do Enunciado): 
    // O Super Joker só pode ser usado 1 vez por jogo e é expressamente proibido na 12ª pergunta (índice 11).
    final bool superJokerDisabled = game.hasUsedSuperJoker || game.currentQuestionIndex == 11;

    // CONTROLO DE ESTADO: Gestão do Modo de Seleção de Jokers
    // Se o tempo esgotar enquanto o jogador escolhe as opções, a pergunta avança externamente.
    // Como não temos um callback direto, detetamos a mudança de pergunta verificando 
    // se o temporizador fez reset para o tempo inicial da fase atual. Se sim, limpamos as seleções.
    if (_jokerSelectionMode && 
        game.eliminatedOptions.isEmpty && 
        !game.hasUsedJokerInCurrentQuestion && 
        game.secondsRemaining == game.getInitialTimeForQuestion(game.currentQuestionIndex)) {
      _jokerSelectionMode = false;
      _selectedForJoker.clear();
    }

    // =========================================================================
    // 3.1. ESTADO DE CARREGAMENTO (LOADING)
    // =========================================================================
    if (game.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF001A4D),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
        ),
      );
    }

    // =========================================================================
    // 3.2. FIM DE JOGO (GAME OVER) - APRESENTAÇÃO DE RESULTADOS
    // =========================================================================
    if (!game.isPlaying) {
      return Scaffold(
        backgroundColor: const Color(0xFF001A4D),
        body: PremiumBackground(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF001A4D),
                      border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.emoji_events, size: 80, color: Color(0xFFD4AF37)),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'FIM DO JOGO!',
                    style: TextStyle(
                      fontSize: 32, 
                      color: Color(0xFFE6C172), 
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Prémio Acumulado',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade400, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${game.currentLevelValue} €', 
                    style: const TextStyle(
                      fontSize: 36, 
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF001A4D),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 6,
                    ),
                    onPressed: () => Navigator.pop(context), 
                    child: const Text(
                      'VOLTAR AO MENU',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }
    // =========================================================================
    // 3.3. SALVAGUARDA DE DADOS EM CARREGAMENTO
    // =========================================================================
    if (game.currentQuestion == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF001A4D),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
        ),
      );
    }
    // Obtém os dados da pergunta ativa vindos do GameProvider
    final pergunta = game.currentQuestion!;
    final options = pergunta['options'] as List<dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xFF001A4D),
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildLogo(),
              
              // SELECÇÃO DE COMPONENTE DE PROGRESSO (Defesa):
              // Exibe a árvore de dinheiro durante o jogo normal (12 perguntas) 
              // ou o contador especial de acertos na Ronda Bónus.
              isInBonusRound ? _buildBonusCounter(game) : _buildMoneyTree(game),
              _buildHeader(game, isInBonusRound),

              // =========================================================================
              // 4. ÁREA DA PERGUNTA E OPÇÕES DE RESPOSTA (UI)
              // =========================================================================
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // TEXTO DA PERGUNTA
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                pergunta['text'].toString().toUpperCase(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE6C172), 
                                  height: 1.4,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black45,
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),

                      // LÓGICA DE APRESENTAÇÃO DE OPÇÕES (Defesa):
                      // - Ronda Bónus: Apenas 2 opções (A e B).
                      // - Ronda Normal: 4 opções de resposta (A, B, C e D) dispostas em grelha 2x2.
                      if (isInBonusRound)
                        Row(
                          children: [
                            Expanded(child: _buildAnswerButton(game, options, 0, 'A')),
                            const SizedBox(width: 12),
                            Expanded(child: _buildAnswerButton(game, options, 1, 'B')),
                          ],
                        )
                      else
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: _buildAnswerButton(game, options, 0, 'A')),
                                const SizedBox(width: 12),
                                Expanded(child: _buildAnswerButton(game, options, 1, 'B')),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: _buildAnswerButton(game, options, 2, 'C')),
                                const SizedBox(width: 12),
                                Expanded(child: _buildAnswerButton(game, options, 3, 'D')),
                              ],
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // =========================================================================
              // 5. PAINEL DE DECISÃO DA 12ª PERGUNTA (REGRA ESPECIAL DE JOGO)
              // =========================================================================
              // VALIDAÇÃO DE REGRA (Decisão na 12ª Pergunta):
              // Na 12ª pergunta (índice 11), se o jogador não tiver usado Joker nessa pergunta,
              // pode decidir não responder para descer apenas 1 patamar na Árvore de Dinheiro,
              // em vez de arriscar errar e descer 3 patamares.
              if (game.currentQuestionIndex == 11)
                Visibility(
                  visible: !game.hasUsedJokerInCurrentQuestion,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A2A2A), 
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: const Color(0xFFD4AF37).withValues(alpha: 0.3), width: 1.5),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          // Envia resposta inválida (-1) indicando desistência nesta pergunta,
                          // acionando a penalização minorada no backend/GameProvider (-1 patamar).
                          game.submitAnswer(-1);
                        },
                        child: const Text(
                          'NÃO RESPONDER (Descer 1 Patamar)',
                          style: TextStyle(
                            color: Color(0xFFB09A51), 
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              _buildJokersFooter(game, superJokerDisabled),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 6. COMPONENTES E AUXILIARES VISUAIS DA UI (MONEY TREE, LOGO, ETC.)
  // =========================================================================

  Widget _buildBonusCounter(GameProvider game) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 4),
      alignment: Alignment.center,
      color: const Color(0xFF001A4D).withValues(alpha: 0.5),
      child: Text(
        'RONDA BÓNUS: PERGUNTA ${game.bonusQuestionIndex + 1}/13 | ACERTOS: ${game.bonusRoundCorrectAnswers}',
        style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontWeight: FontWeight.w900,
          fontSize: 15,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: const Color(0xFF001A4D),
              border: const Border.symmetric(
                horizontal: BorderSide(
                  color: Color(0xFFD4AF37),
                  width: 2.0,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          Container(
            width: 150,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF001A4D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFD4AF37),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                  blurRadius: 12,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              'JOKER',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFFE6C172),
                letterSpacing: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CONSTRUÇÃO DA ÁRVORE DE DINHEIRO (MONEY TREE)
  // Renderiza uma lista horizontal (com ordem reversa de modo a que os maiores valores fiquem visíveis)
  // dos patamares monetários definidos no enunciado: [0, 200, 500, 1000, 3000, 10000, 50000].
  // Destaca visualmente o patamar ativo atual do jogador.
  Widget _buildMoneyTree(GameProvider game) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: const Color(0xFF001A4D).withValues(alpha: 0.5),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true, 
        itemCount: game.moneyTree.length,
        itemBuilder: (context, index) {
          bool isCurrent = index == game.currentLevelIndex;
          bool isPassed = index < game.currentLevelIndex;

          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              color: isCurrent 
                  ? const Color(0xFFD4AF37) 
                  : (isPassed ? const Color(0xFFD4AF37).withValues(alpha: 0.25) : Colors.black38),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCurrent ? const Color(0xFFE6C172) : Colors.transparent, 
                width: 1.5,
              ),
              boxShadow: isCurrent ? [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                )
              ] : null,
            ),
            child: Text(
              '${game.moneyTree[index]} €',
              style: TextStyle(
                color: isCurrent ? const Color(0xFF001A4D) : const Color(0xFFE6C172),
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          );
        },
      ),
    );
  }

  // CABEÇALHO DO JOGO: Exibe o progresso das perguntas (ex: Pergunta 3 de 12)
  // e o temporizador de contagem decrescente com efeito visual circular diferenciado.
  Widget _buildHeader(GameProvider game, bool isInBonusRound) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isInBonusRound ? 'RONDA BÓNUS' : 'PERGUNTA ${game.currentQuestionIndex + 1} DE 12',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: isInBonusRound ? const Color(0xFFFFD700) : const Color(0xFFE6C172),
              letterSpacing: 1.5,
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isInBonusRound ? const Color(0xFFD4AF37).withValues(alpha: 0.2) : const Color(0xFF001A4D),
              border: Border.all(
                color: isInBonusRound ? const Color(0xFFFFD700) : const Color(0xFFD4AF37),
                width: isInBonusRound ? 3.5 : 2.5,
              ),
              boxShadow: isInBonusRound 
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                : [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                      blurRadius: 6,
                    ),
                  ],
            ),
            alignment: Alignment.center,
            child: Text(
              game.secondsRemaining.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isInBonusRound ? const Color(0xFFFFD700) : const Color(0xFFE6C172),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 7. CONSTRUÇÃO DO FOOTER E PAINEL DE CONTROLO DE JOKERS
  // =========================================================================
  
  // PAINEL DE CONTROLO DE JOKERS (Defesa):
  // Exibe o número de Jokers normais restantes (representados graficamente por mini-cartas)
  // e os botões de ação para ativar o Super Joker e o Joker Normal.
  Widget _buildJokersFooter(GameProvider game, bool superJokerDisabled) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFF001A4D),
        border: Border(
          top: BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildJokerCardsStack(),
              const SizedBox(width: 8),
              Text(
                'RESTANTES: ${game.jokersRemaining}',
                style: const TextStyle(
                  color: Color(0xFFE6C172),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          Row(
            children: [
              Opacity(
                opacity: superJokerDisabled ? 0.3 : 1.0,
                child: OutlinedButton.icon(
                  onPressed: superJokerDisabled ? null : () {
                    game.useSuperJoker();
                  },
                  icon: const Icon(Icons.access_time_rounded, color: Color(0xFFD4AF37), size: 16),
                  label: const Text(
                    'SUPER (+30s)',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              if (game.jokersRemaining > 0 && !game.hasUsedJokerInCurrentQuestion)
                ElevatedButton(
                  onPressed: () {
                    // LÓGICA DO JOKER NORMAL (2 Fases):
                    // Fase 1: Ativa o modo de seleção (_jokerSelectionMode = true)
                    // Fase 2: Valida se _selectedForJoker tem exatamente 2 elementos.
                    // Se sim, invoca game.useStandardJoker enviando os textos das opções escolhidas e a opção correta.
                    if (!_jokerSelectionMode) {
                      setState(() {
                        _jokerSelectionMode = true;
                        _selectedForJoker.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecione 2 opções e pressione CONFIRMAR.')),
                      );
                    } else {
                      // Fase 2: Execução com Validação de Exatamente 2 Opções
                      if (_selectedForJoker.length == 2) {
                        final options = game.currentQuestion!['options'] as List<dynamic>;
                        final optA = options[_selectedForJoker[0]].toString();
                        final optB = options[_selectedForJoker[1]].toString();
                        final correctOpt = options[game.currentQuestion!['correctIndex']].toString();
                        
                        // Executa a lógica de descarte de opção incorreta
                        game.useStandardJoker(optA, optB, correctOpt);
                        
                        // Reseta o estado local do ecrã após a utilização
                        setState(() {
                          _jokerSelectionMode = false;
                          _selectedForJoker.clear();
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tem de selecionar exatamente 2 opções!')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _jokerSelectionMode ? Colors.green.shade600 : const Color(0xFFD4AF37),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                  ),
                  child: Row(
                    children: [
                      Icon(_jokerSelectionMode ? Icons.check_circle_outline : Icons.help_outline, color: const Color(0xFF001A4D), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _jokerSelectionMode ? 'CONFIRMAR' : 'JOKER',
                        style: const TextStyle(
                          color: Color(0xFF001A4D),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJokerCardsStack() {
    return SizedBox(
      width: 40,
      height: 30,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: Transform.rotate(
              angle: -0.2,
              child: _buildMiniCard(),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 2,
            child: Transform.rotate(
              angle: 0,
              child: _buildMiniCard(),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 0,
            child: Transform.rotate(
              angle: 0.2,
              child: _buildMiniCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard() {
    return Container(
      width: 16,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFF001A4D),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'J',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// 8. COMPONENTE WIDGET PERSONALIZADO: BOTÃO DE RESPOSTA (ANSWER BUTTON)
// =========================================================================
// Representa visualmente cada opção de resposta (A, B, C, D) com
// feedback visual dinâmico em caso de seleção normal ou seleção para modo Joker.
class AnswerButton extends StatefulWidget {
  final String label; 
  final String text;
  final VoidCallback onPressed;
  final bool isSelected;
  final bool isSelectionMode;

  const AnswerButton({
    super.key,
    required this.label,
    required this.text,
    required this.onPressed,
    this.isSelected = false,
    this.isSelectionMode = false,
  });

  @override
  State<AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<AnswerButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool highlighted = widget.isSelected || _isPressed;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: widget.isSelected ? const Color(0xFFD4AF37).withValues(alpha: 0.15) : const Color(0xFF001A4D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: highlighted ? const Color(0xFFFFD700) : const Color(0xFFD4AF37),
            width: highlighted ? 3.5 : 1.5, 
          ),
          boxShadow: [
            BoxShadow(
              color: highlighted ? const Color(0xFFFFD700).withValues(alpha: 0.8) : const Color(0xFFD4AF37).withValues(alpha: 0.2),
              blurRadius: highlighted ? 12 : 4,
              spreadRadius: highlighted ? 2 : 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
        child: RichText(
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          text: TextSpan(
            children: [
              TextSpan(
                text: '[${widget.label}] ',
                style: const TextStyle(
                  color: Color(0xFFE6C172),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text: widget.text,
                style: const TextStyle(
                  color: Color(0xFFE6C172),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// 9. CLASSES AUXILIARES E DETALHES DE ESTILO PREMIUM
// =========================================================================

// Fundo Premium com Gradiente Radial e padrão geométrico para dar
// um aspeto televisivo e refinado ao ecrã do Joker.
class PremiumBackground extends StatelessWidget {
  final Widget child;

  const PremiumBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Color(0xFF002B7A), 
            Color(0xFF001A4D), 
          ],
          radius: 1.2,
          center: Alignment.topCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(
                painter: GeometricPatternPainter(),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, 0);
    for (double r = 100; r < size.height; r += 120) {
      canvas.drawCircle(center, r, paint);
    }

    for (double x = -100; x < size.width + 100; x += 100) {
      canvas.drawLine(Offset(x, 0), Offset(x + 300, size.height), paint);
      canvas.drawLine(Offset(x, 0), Offset(x - 300, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
