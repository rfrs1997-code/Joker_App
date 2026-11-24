namespace Joker.API.Models
{
    public class Question
    {
        public int Id { get; set; }
        public string Text { get; set; } = string.Empty;
        
        // Opções de resposta
        public string OptionA { get; set; } = string.Empty;
        public string OptionB { get; set; } = string.Empty;
        public string? OptionC { get; set; }
        public string? OptionD { get; set; }
        
        // A resposta correta ('A', 'B', 'C', ou 'D')
        public char CorrectOption { get; set; } 
        
        // Nível na árvore do dinheiro (1 a 12)
        public int DifficultyLevel { get; set; } 
    }
}
