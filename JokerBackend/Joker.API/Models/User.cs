using System;
using System.Collections.Generic;

namespace Joker.API.Models
{
    public class User
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public string Name { get; set; } = string.Empty;
        public string Username { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PasswordHash { get; set; } = string.Empty;
        public string ProfilePicture { get; set; } = string.Empty; // Pode ser um URL ou base64
        
        // Campo extra para facilitar a extração rápida do ranking global
        public int HighScore { get; set; } = 0; 
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Relacionamento: Um utilizador tem vários resultados de jogos
        public ICollection<GameResult> GameResults { get; set; } = new List<GameResult>();
    }
}
