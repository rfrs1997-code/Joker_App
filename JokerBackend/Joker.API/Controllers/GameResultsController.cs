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
    public class GameResultsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public GameResultsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpPost]
        [Authorize] // Só utilizadores com sessão iniciada podem enviar resultados
        public async Task<IActionResult> SubmitResult(SubmitResultDto request)
        {
            // Extrair o ID do utilizador a partir do token JWT
            var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out Guid userId))
            {
                return Unauthorized("Utilizador inválido.");
            }

            // Procurar o utilizador na base de dados
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

            // Atualizar o HighScore se o prémio desta partida for maior que o recorde anterior
            if (request.MoneyWon > user.HighScore)
            {
                user.HighScore = request.MoneyWon;
                _context.Users.Update(user);
            }

            await _context.SaveChangesAsync();

            return Ok(new { Message = "Resultado guardado com sucesso!", NewHighScore = user.HighScore });
        }

        [HttpGet("stats")]
        [Authorize]
        public async Task<IActionResult> GetPlayerStats()
        {
            var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out Guid userId))
            {
                return Unauthorized("Utilizador inválido.");
            }

            var results = await _context.GameResults
                .Where(r => r.UserId == userId)
                .ToListAsync();

            var maxPrize = results.Any() ? results.Max(r => r.MoneyWon) : 0;
            var maxLevel = results.Any() ? results.Max(r => r.LevelReached) : 0;
            var gamesPlayed = results.Count;

            return Ok(new
            {
                maxPrize = maxPrize,
                maxLevel = maxLevel,
                gamesPlayed = gamesPlayed
            });
        }

        [HttpGet("leaderboard")]
        // Endpoint público ou protegido? Normalmente o ranking pode ser público.
        public async Task<IActionResult> GetLeaderboard()
        {
            // Devolver o Top 10 de utilizadores ordenado pelo maior HighScore
            var leaderboard = await _context.Users
                .OrderByDescending(u => u.HighScore)
                .Take(10)
                .Select(u => new LeaderboardResponseDto
                {
                    Username = u.Username,
                    ProfilePicture = string.IsNullOrEmpty(u.ProfilePicture) ? "" : u.ProfilePicture,
                    HighScore = u.HighScore
                })
                .ToListAsync();

            return Ok(leaderboard);
        }
    }
}
