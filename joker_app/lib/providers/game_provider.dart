import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

// =========================================================================
// GESTÃO DE ESTADO DO JOGO (GAME PROVIDER)
// =========================================================================
// Responsável por manter e atualizar o estado do jogo (pontuação, nível,
// jokers, tempo restante, etc.) e comunicar com o backend via API.
class GameProvider with ChangeNotifier {
  // =========================================================================
  // 1. ATRIBUTOS E ESTADO DE JOGO (STATE)
  // =========================================================================
  final ApiService _apiService = ApiService();
  final List<int> moneyTree = [0, 200, 500, 1000, 3000, 10000, 50000];
  
  List<Map<String, dynamic>> _normalQuestions = [];
  List<Map<String, dynamic>> _bonusQuestions = [];
  int _currentLevelIndex = 0;
  int _currentQuestionIndex = 0;
  int _jokersRemaining = 7;
  int _secondsRemaining = 30;
  bool _isPlaying = false;
  bool _isLoading = false; // Estado para gerir o loading de perguntas
  Timer? _timer;

  // Variáveis da Ronda Bónus
  bool _isBonusRoundActive = false;
  int _bonusQuestionIndex = 0;
  int _bonusRoundsCompleted = 0;
  int _bonusRoundCorrectAnswers = 0;
  int _bonusRoundWrongAnswers = 0;

  bool hasUsedSuperJoker = false;
  bool hasUsedJokerInCurrentQuestion = false;
  List<String> eliminatedOptions = []; // Opções de resposta a ocultar na UI

  // Getters
  int get currentLevelIndex => _currentLevelIndex;
  int get currentLevelValue => moneyTree[_currentLevelIndex];
  int get currentQuestionIndex => _currentQuestionIndex;
  int get jokersRemaining => _jokersRemaining;
  int get secondsRemaining => _secondsRemaining;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;

  bool get isBonusRoundActive => _isBonusRoundActive;
  int get bonusQuestionIndex => _bonusQuestionIndex;
  int get bonusRoundsCompleted => _bonusRoundsCompleted;
  int get bonusRoundCorrectAnswers => _bonusRoundCorrectAnswers;
  int get bonusRoundWrongAnswers => _bonusRoundWrongAnswers;

  Map<String, dynamic>? get currentQuestion {
    if (_isBonusRoundActive) {
      int index = (_bonusRoundsCompleted * 13) + _bonusQuestionIndex;
      if (_bonusQuestions.isNotEmpty && index < _bonusQuestions.length) {
        return _bonusQuestions[index];
      }
      return null;
    } else {
      if (_normalQuestions.isNotEmpty && _currentQuestionIndex < _normalQuestions.length) {
        return _normalQuestions[_currentQuestionIndex];
      }
      return null;
    }
  }

  // =========================================================================
  // 2. REGRAS DE NEGÓCIO: TEMPORIZADOR E CONTROLO DE TEMPO
  // =========================================================================

  // REGRA DE NEGÓCIO (Secção 3.5 do Enunciado): 
  // O tempo disponível para resposta aumenta progressivamente conforme a fase do jogo:
  // - Perguntas 1 a 4 (índices 0-3): 30 segundos
  // - Perguntas 5 a 8 (índices 4-7): 40 segundos
  // - Perguntas 9 a 12 (índices 8-11): 50 segundos
  int getInitialTimeForQuestion(int questionIndex) {
    // REGRA DE NEGÓCIO (Ronda Bónus):
    // As perguntas da Ronda Bónus têm um tempo limite curto de 10 segundos.
    if (_isBonusRoundActive) {
      return 10;
    }

    if (questionIndex >= 0 && questionIndex <= 3) {
      return 30;
    } else if (questionIndex >= 4 && questionIndex <= 7) {
      return 40;
    } else if (questionIndex >= 8 && questionIndex <= 11) {
      return 50;
    }
    return 30; // Valor padrão de salvaguarda
  }

  // =========================================================================
  // 3. FLUXO DE INICIALIZAÇÃO DA PARTIDA E TEMPORIZADORES
  // =========================================================================

  /// Inicia uma nova partida descarregando as perguntas do backend/API.
  Future<void> startGame() async {
    _isLoading = true;
    notifyListeners();

    final listaPerguntas = await _apiService.getQuestions();

    if (listaPerguntas != null && listaPerguntas.isNotEmpty) {
      _normalQuestions = listaPerguntas.where((q) => (q['options'] as List).length >= 4).toList();
      _bonusQuestions = listaPerguntas.where((q) => (q['options'] as List).length == 2).toList();
      
      print(' DEBUG: Perguntas Normais carregadas: ${_normalQuestions.length}');
      print(' DEBUG: Perguntas Bónus carregadas: ${_bonusQuestions.length}');
      
      _currentLevelIndex = 0;
      _currentQuestionIndex = 0;
      _jokersRemaining = 7; // Começa com 7 Jokers (Regra 3.2)
      
      _isBonusRoundActive = false;
      _bonusQuestionIndex = 0;
      _bonusRoundsCompleted = 0;
      _bonusRoundCorrectAnswers = 0;
      _bonusRoundWrongAnswers = 0;

      hasUsedSuperJoker = false;
      hasUsedJokerInCurrentQuestion = false;
      eliminatedOptions.clear();

      _isPlaying = true;
      _isLoading = false;
      _startTimer();
    } else {
      _isLoading = false;
      _isPlaying = false;
    }
    notifyListeners();
  }

  // CONTROLO DO FLUXO DO TEMPORIZADOR:
  // Inicia um Timer periódico de 1 segundo. Se o tempo expirar (chegar a 0),
  // executa automaticamente a submissão de resposta com código -1 (tempo esgotado/errado).
  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = getInitialTimeForQuestion(_currentQuestionIndex);
    hasUsedJokerInCurrentQuestion = false;
    eliminatedOptions.clear();
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _timer?.cancel();
        submitAnswer(-1); // Tempo esgotado = Resposta errada (-1)
      }
    });
  }

  // =========================================================================
  // 4. REGRAS DE NEGÓCIO: SUBMISSÃO DE RESPOSTAS E PATAMARES (MONEY TREE)
  // =========================================================================

  // PONTUAÇÃO E PENALIZAÇÕES (Secção 3.1, 3.3 e 3.4 do Enunciado):
  // 1. Resposta Correta: Sobe 1 nível na Árvore de Dinheiro (moneyTree).
  // 2. Resposta Incorreta: 
  //    - Se tiver pelo menos 3 Jokers, perde 3 Jokers (e mantém o nível atual).
  //    - Se tiver menos de 3 Jokers (ex: 2, 1 ou 0), perde todos os Jokers restantes 
  //      e desce 3 patamares na Árvore de Dinheiro (clamped a 0 para não ficar negativo).
  //    - Se for na 12ª pergunta e decidir não responder (selectedIndex == -1), 
  //      a penalização é atenuada descendo apenas 1 patamar e mantendo o prémio daí decorrente.
  // 3. Fim do Jogo: Ao atingir as 12 perguntas, submete a pontuação final via API e termina a partida.
  Future<void> submitAnswer(int selectedIndex) async {
    _timer?.cancel();
    final question = currentQuestion;
    if (question == null) return;

    if (_isBonusRoundActive) {
      // REGRA DE NEGÓCIO (Ronda Bónus):
      // Processa a resposta como sendo bónus e contabiliza acertos/erros.
      if (selectedIndex == question['correctIndex']) {
        _bonusRoundCorrectAnswers++;
      } else {
        _bonusRoundWrongAnswers++;
      }
      _bonusQuestionIndex++;

      // Quando atingir 13, finaliza a ronda bónus
      if (_bonusQuestionIndex >= 13) {
        if (_bonusRoundCorrectAnswers >= 10 && _bonusRoundWrongAnswers <= 3) {
          _jokersRemaining += 2;
        } else if (_bonusRoundCorrectAnswers >= 5) {
          _jokersRemaining += 1;
        }
        
        _isBonusRoundActive = false;
        _bonusRoundsCompleted++;
        
        // Retoma a contagem de tempo para a pergunta normal que estava em espera
        _startTimer();
      } else {
        // Avança para a próxima pergunta da ronda bónus
        _startTimer();
      }
      notifyListeners();
      return;
    }

    // Lógica da Ronda Normal
    if (selectedIndex == question['correctIndex']) {
      // Sobe 1 patamar se acertar
      if (_currentLevelIndex < moneyTree.length - 1) {
        _currentLevelIndex++;
      }
    } else {
      // Lógica de penalização por erro ou não-resposta (tempo esgotado/desistência)
      if (_currentQuestionIndex == 11 && selectedIndex == -1) {
        // REGRA DE EXCEPÇÃO (12ª pergunta sem resposta): Desce apenas 1 patamar
        _currentLevelIndex = (_currentLevelIndex - 1).clamp(0, moneyTree.length - 1);
      } else {
        // REGRA GERAL DE PENALIZAÇÃO:
        if (_jokersRemaining >= 3) {
          _jokersRemaining -= 3; // Consome 3 Jokers e mantém o prémio
        } else {
          // Perde os jokers que tem e desce 3 patamares na árvore
          _jokersRemaining = 0;
          _currentLevelIndex = (_currentLevelIndex - 3).clamp(0, moneyTree.length - 1);
        }
      }
    }

    _currentQuestionIndex++;

    // REGRA DE NEGÓCIO (Interrupção Ronda Bónus):
    // Ao concluir a 4ª pergunta normal (index passa a 4) e a 8ª pergunta normal (index passa a 8), 
    // inicia uma ronda bónus.
    if (_currentQuestionIndex == 4 || _currentQuestionIndex == 8) {
      _isBonusRoundActive = true;
      _bonusQuestionIndex = 0;
      _bonusRoundCorrectAnswers = 0;
      _bonusRoundWrongAnswers = 0;
      _startTimer();
      notifyListeners();
      return;
    }

    // Fim de jogo normal (12 perguntas concluidas)
    if (_currentQuestionIndex >= 12 || _currentQuestionIndex >= _normalQuestions.length) {
      _isPlaying = false;
      // Submete a pontuação final (índice de nível e valor monetário) para o servidor
      await _apiService.submitScore(_currentLevelIndex, currentLevelValue);
    } else {
      _startTimer();
    }

    notifyListeners();
  }

  // =========================================================================
  // 5. REGRAS DE NEGÓCIO: UTILIZAÇÃO DE JOKERS (SUPER & STANDARD)
  // =========================================================================

  // VALIDAÇÃO DE REGRA (Secção 3.6 - Super Joker):
  // O Super Joker adiciona 30 segundos de reflexão ao tempo e só pode ser usado 1 vez por jogo.
  // É estritamente proibido o seu uso na 12ª pergunta (índice 11) para evitar facilitação no patamar final.
  void useSuperJoker() {
    if (hasUsedSuperJoker || _currentQuestionIndex == 11) {
      return;
    }

    hasUsedSuperJoker = true;
    _secondsRemaining += 30;
    
    // Notifica ouvintes para redesenhar o temporizador imediatamente na UI
    notifyListeners(); 
  }

  // VALIDAÇÃO DE REGRA (Secção 3.2 - Joker Standard):
  // 1. Consome 1 Joker do saldo disponível.
  // 2. Adiciona 15 segundos extra obrigatórios ao temporizador.
  // 3. Elimina uma das duas opções selecionadas pelo jogador que seja comprovadamente incorreta.
  void useStandardJoker(String optionA, String optionB, String correctOption) {
    if (_jokersRemaining <= 0 || hasUsedJokerInCurrentQuestion) return;

    _jokersRemaining--;
    hasUsedJokerInCurrentQuestion = true;
    _secondsRemaining += 15;

    // Lógica de Descarte:
    if (optionA == correctOption || optionB == correctOption) {
      // Se uma das opções é a correta, descarta a outra (incorreta)
      String incorrect = (optionA == correctOption) ? optionB : optionA;
      eliminatedOptions.add(incorrect);
    } else {
      // Se ambas forem incorretas, descarta a primeira selecionada
      eliminatedOptions.add(optionA);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
