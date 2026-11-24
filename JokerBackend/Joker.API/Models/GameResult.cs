using System;

namespace Joker.API.Models
{
    public class GameResult
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        
        // Chave estrangeira para o Utilizador
        public Guid UserId { get; set; }
        public User? User { get; set; }

        // O nível alcançado na árvore do dinheiro (0 a 12)
        public int LevelReached { get; set; }
        
        // Valor monetário correspondente (ex: 0, 200, 500, 1000, 3000, 10000, 50000.)
        public int MoneyWon { get; set; }
        
        public DateTime DatePlayed { get; set; } = DateTime.UtcNow;
    }
}
