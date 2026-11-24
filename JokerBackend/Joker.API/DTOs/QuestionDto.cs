namespace Joker.API.DTOs
{
    /// <summary>
    /// DTO que representa uma pergunta enviada para o cliente Flutter.
    /// Oculta os detalhes internos da base de dados (chave primária, char CorrectOption)
    /// e converte as opções A/B/C/D numa lista indexada de 0 a 3.
    /// </summary>
    public class QuestionDto
    {
        public string Text { get; set; } = string.Empty;
        
        // Lista com as 4 opções de resposta (índices 0 a 3)
        public List<string> Options { get; set; } = new List<string>();
        
        // Índice da resposta correta na lista acima (0=A, 1=B, 2=C, 3=D)
        // Nota: Em produção, este campo DEVE ser removido e a validação feita exclusivamente no servidor.
        // Para efeitos académicos, é enviado para que a lógica de jogo funcione no cliente.
        public int CorrectIndex { get; set; }
        
        // Nível de dificuldade (1 a 12) para referência
        public int DifficultyLevel { get; set; }
    }
}
