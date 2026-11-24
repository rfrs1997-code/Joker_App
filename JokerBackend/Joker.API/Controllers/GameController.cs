using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using Joker.API.Data;
using Joker.API.DTOs;
using Joker.API.Models;

namespace Joker.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize] // Garante que só utilizadores com Token válido (autenticados) podem aceder
    public class GameController : ControllerBase
    {
        private readonly AppDbContext _context;

        public GameController(AppDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Devolve 12 perguntas aleatórias (1 por nível) mapeadas para QuestionDto.
        /// O Flutter recebe apenas o texto e as opções — sem chaves de base de dados.
        /// Rota: GET /api/Game/questions
        /// </summary>
        [HttpGet("questions")]
        public async Task<IActionResult> GetQuestions()
        {
            var questionDtos = new List<QuestionDto>();

            // O jogo tem 12 níveis. Vamos buscar 1 pergunta aleatória por nível.
            for (int level = 1; level <= 12; level++)
            {
                var question = await _context.Questions
                    .Where(q => q.DifficultyLevel == level)
                    .OrderBy(q => Guid.NewGuid()) // Ordenação aleatória
                    .FirstOrDefaultAsync();

                if (question != null)
                {
                    questionDtos.Add(MapToDto(question));
                }
            }

            // Buscar 26 perguntas aleatórias de nível 0 (Bónus)
            var bonusQuestions = await _context.Questions
                .Where(q => q.DifficultyLevel == 0)
                .OrderBy(q => Guid.NewGuid())
                .Take(26)
                .ToListAsync();

            foreach (var q in bonusQuestions)
            {
                questionDtos.Add(MapToDto(q));
            }

            // Se a base de dados ainda não tiver nenhuma pergunta, avisa o cliente.
            if (questionDtos.Count == 0)
            {
                return BadRequest("Não foi encontrada nenhuma pergunta na base de dados.");
            }

            return Ok(questionDtos);
        }

        /// <summary>
        /// Guarda o resultado final de uma partida e actualiza o HighScore do utilizador se aplicável.
        /// Rota: POST /api/Game/submit-score
        /// </summary>
        [HttpPost("submit-score")]
        public async Task<IActionResult> SubmitScore([FromBody] SubmitResultDto request)
        {
            // Extrair o ID do utilizador a partir do token JWT
            var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out Guid userId))
            {
                return Unauthorized("Utilizador inválido.");
            }

            var user = await _context.Users.FindAsync(userId);
            if (user == null)
            {
                return NotFound("Utilizador não encontrado.");
            }

            // Criar e guardar o resultado da partida
            var gameResult = new GameResult
            {
                UserId = userId,
                LevelReached = request.LevelReached,
                MoneyWon = request.MoneyWon,
                DatePlayed = DateTime.UtcNow
            };

            _context.GameResults.Add(gameResult);

            // Actualizar o HighScore se o prémio desta partida for maior que o recorde anterior
            if (request.MoneyWon > user.HighScore)
            {
                user.HighScore = request.MoneyWon;
                _context.Users.Update(user);
            }

            await _context.SaveChangesAsync();

            return Ok(new
            {
                Message = "Resultado guardado com sucesso!",
                MoneyWon = request.MoneyWon,
                NewHighScore = user.HighScore
            });
        }

        // --- Método auxiliar privado ---

        /// <summary>
        /// Converte a entidade Question (com OptionA/B/C/D e CorrectOption como char)
        /// para o QuestionDto limpo que o Flutter espera (lista indexada de 0 a 3).
        /// </summary>
        private static QuestionDto MapToDto(Question q)
        {
            // Filtra as opções nulas/vazias garantindo que as perguntas bónus ficam apenas com tamanho 2.
            var options = new List<string> { q.OptionA, q.OptionB, q.OptionC, q.OptionD }
                .Where(o => !string.IsNullOrEmpty(o))
                .ToList();

            // Converte o char 'A','B','C','D' para o índice 0,1,2,3
            int correctIndex = q.CorrectOption switch
            {
                'A' => 0,
                'B' => 1,
                'C' => 2,
                'D' => 3,
                _   => 0
            };

            return new QuestionDto
            {
                Text = q.Text,
                Options = options,
                CorrectIndex = correctIndex,
                DifficultyLevel = q.DifficultyLevel
            };
        }
    }
}
