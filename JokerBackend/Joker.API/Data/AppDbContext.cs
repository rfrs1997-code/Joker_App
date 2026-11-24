using Microsoft.EntityFrameworkCore;
using Joker.API.Models;

/*
    Contexto da Aplicação
    Autor: Rui Sousa
    Descrição: Contexto da Aplicação
    Atualização: Adição de relação entre Utilizador e Resultados de Jogos
*/
namespace Joker.API.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<Question> Questions { get; set; }
        public DbSet<GameResult> GameResults { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Garantir que o Username e o Email são únicos
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Username)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();
                
            // Relacionamento 1 para Muitos (Utilizador -> Resultados)
            modelBuilder.Entity<GameResult>()
                .HasOne(g => g.User)
                .WithMany(u => u.GameResults)
                .HasForeignKey(g => g.UserId);

            // Inserir perguntas base (36 perguntas, 3 por nível de 1 a 12)
            modelBuilder.Entity<Question>().HasData(
                // Nível 1
                new Question { Id = 1, DifficultyLevel = 1, Text = "Qual é a capital de Portugal?", OptionA = "Porto", OptionB = "Faro", OptionC = "Lisboa", OptionD = "Coimbra", CorrectOption = 'C' },
                new Question { Id = 2, DifficultyLevel = 1, Text = "Quantas cores tem a bandeira portuguesa?", OptionA = "Duas", OptionB = "Três", OptionC = "Quatro", OptionD = "Cinco", CorrectOption = 'B' },
                new Question { Id = 3, DifficultyLevel = 1, Text = "Que rio desagua na cidade do Porto?", OptionA = "Tejo", OptionB = "Douro", OptionC = "Minho", OptionD = "Guadiana", CorrectOption = 'B' },
                // Nível 2
                new Question { Id = 4, DifficultyLevel = 2, Text = "Qual é o maior planeta do sistema solar?", OptionA = "Júpiter", OptionB = "Marte", OptionC = "Terra", OptionD = "Saturno", CorrectOption = 'A' },
                new Question { Id = 5, DifficultyLevel = 2, Text = "Quantos dias tem um ano bissexto?", OptionA = "364", OptionB = "365", OptionC = "366", OptionD = "367", CorrectOption = 'C' },
                new Question { Id = 6, DifficultyLevel = 2, Text = "Quem escreveu \"Os Lusíadas\"?", OptionA = "Fernando Pessoa", OptionB = "José Saramago", OptionC = "Eça de Queirós", OptionD = "Luís de Camões", CorrectOption = 'D' },
                // Nível 3
                new Question { Id = 7, DifficultyLevel = 3, Text = "Qual o metal cujo símbolo químico é Au?", OptionA = "Prata", OptionB = "Ouro", OptionC = "Ferro", OptionD = "Cobre", CorrectOption = 'B' },
                new Question { Id = 8, DifficultyLevel = 3, Text = "Em que continente fica o Egipto?", OptionA = "África", OptionB = "Ásia", OptionC = "Europa", OptionD = "América", CorrectOption = 'A' },
                new Question { Id = 9, DifficultyLevel = 3, Text = "Qual é o oceano que banha a costa de Portugal?", OptionA = "Índico", OptionB = "Pacífico", OptionC = "Atlântico", OptionD = "Ártico", CorrectOption = 'C' },
                // Nível 4
                new Question { Id = 10, DifficultyLevel = 4, Text = "Quantos cantos têm \"Os Lusíadas\"?", OptionA = "Oito", OptionB = "Dez", OptionC = "Doze", OptionD = "Nove", CorrectOption = 'B' },
                new Question { Id = 11, DifficultyLevel = 4, Text = "Qual foi o primeiro rei de Portugal?", OptionA = "D. Sancho I", OptionB = "D. Dinis", OptionC = "D. Afonso Henriques", OptionD = "D. João I", CorrectOption = 'C' },
                new Question { Id = 12, DifficultyLevel = 4, Text = "Em que ano se deu o 25 de Abril?", OptionA = "1972", OptionB = "1974", OptionC = "1975", OptionD = "1976", CorrectOption = 'B' },
                // Nível 5
                new Question { Id = 13, DifficultyLevel = 5, Text = "Qual o osso mais longo do corpo humano?", OptionA = "Tíbia", OptionB = "Rádio", OptionC = "Úmero", OptionD = "Fémur", CorrectOption = 'D' },
                new Question { Id = 14, DifficultyLevel = 5, Text = "Qual o animal terrestre mais rápido?", OptionA = "Gepardo", OptionB = "Leão", OptionC = "Tigre", OptionD = "Gazela", CorrectOption = 'A' },
                new Question { Id = 15, DifficultyLevel = 5, Text = "Quem pintou a Mona Lisa?", OptionA = "Picasso", OptionB = "Leonardo da Vinci", OptionC = "Van Gogh", OptionD = "Dalí", CorrectOption = 'B' },
                // Nível 6
                new Question { Id = 16, DifficultyLevel = 6, Text = "De que banda era vocalista Freddie Mercury?", OptionA = "The Beatles", OptionB = "Rolling Stones", OptionC = "Queen", OptionD = "Pink Floyd", CorrectOption = 'C' },
                new Question { Id = 17, DifficultyLevel = 6, Text = "Qual a língua nativa mais falada no mundo?", OptionA = "Mandarim", OptionB = "Espanhol", OptionC = "Inglês", OptionD = "Hindi", CorrectOption = 'A' },
                new Question { Id = 18, DifficultyLevel = 6, Text = "Que país ofereceu a Estátua da Liberdade aos EUA?", OptionA = "Inglaterra", OptionB = "Espanha", OptionC = "Itália", OptionD = "França", CorrectOption = 'D' },
                // Nível 7
                new Question { Id = 19, DifficultyLevel = 7, Text = "Qual é o deserto mais quente do mundo?", OptionA = "Gobi", OptionB = "Sara", OptionC = "Atacama", OptionD = "Kalahari", CorrectOption = 'B' },
                new Question { Id = 20, DifficultyLevel = 7, Text = "Quem foi o primeiro homem a pisar a lua?", OptionA = "Neil Armstrong", OptionB = "Yuri Gagarin", OptionC = "Buzz Aldrin", OptionD = "Michael Collins", CorrectOption = 'A' },
                new Question { Id = 21, DifficultyLevel = 7, Text = "Qual é o menor país do mundo?", OptionA = "Mónaco", OptionB = "San Marino", OptionC = "Vaticano", OptionD = "Liechtenstein", CorrectOption = 'C' },
                // Nível 8
                new Question { Id = 22, DifficultyLevel = 8, Text = "Em que ano terminou a Segunda Guerra Mundial?", OptionA = "1943", OptionB = "1945", OptionC = "1947", OptionD = "1950", CorrectOption = 'B' },
                new Question { Id = 23, DifficultyLevel = 8, Text = "Qual o elemento mais abundante no universo?", OptionA = "Oxigénio", OptionB = "Carbono", OptionC = "Hidrogénio", OptionD = "Hélio", CorrectOption = 'C' },
                new Question { Id = 24, DifficultyLevel = 8, Text = "Qual o nome do inventor da lâmpada elétrica comercial?", OptionA = "Thomas Edison", OptionB = "Nikola Tesla", OptionC = "Alexander Bell", OptionD = "Albert Einstein", CorrectOption = 'A' },
                // Nível 9
                new Question { Id = 25, DifficultyLevel = 9, Text = "Quem realizou o filme \"O Padrinho\"?", OptionA = "Steven Spielberg", OptionB = "Francis Ford Coppola", OptionC = "Martin Scorsese", OptionD = "Quentin Tarantino", CorrectOption = 'B' },
                new Question { Id = 26, DifficultyLevel = 9, Text = "Qual a fórmula química do ozono?", OptionA = "O2", OptionB = "CO2", OptionC = "H2O", OptionD = "O3", CorrectOption = 'D' },
                new Question { Id = 27, DifficultyLevel = 9, Text = "Que país venceu o primeiro mundial de futebol em 1930?", OptionA = "Brasil", OptionB = "Argentina", OptionC = "Uruguai", OptionD = "Itália", CorrectOption = 'C' },
                // Nível 10
                new Question { Id = 28, DifficultyLevel = 10, Text = "Qual o tratado que dividiu o mundo novo entre Portugal e Espanha?", OptionA = "Tordesilhas", OptionB = "Versalhes", OptionC = "Madrid", OptionD = "Paris", CorrectOption = 'A' },
                new Question { Id = 29, DifficultyLevel = 10, Text = "Qual a obra mais famosa de Miguel de Cervantes?", OptionA = "Os Lusíadas", OptionB = "Dom Quixote", OptionC = "Hamlet", OptionD = "A Divina Comédia", CorrectOption = 'B' },
                new Question { Id = 30, DifficultyLevel = 10, Text = "Qual o ácido presente no vinagre?", OptionA = "Ácido cítrico", OptionB = "Ácido sulfúrico", OptionC = "Ácido clorídrico", OptionD = "Ácido acético", CorrectOption = 'D' },
                // Nível 11
                new Question { Id = 31, DifficultyLevel = 11, Text = "Quem descobriu a penicilina?", OptionA = "Marie Curie", OptionB = "Louis Pasteur", OptionC = "Alexander Fleming", OptionD = "Isaac Newton", CorrectOption = 'C' },
                new Question { Id = 32, DifficultyLevel = 11, Text = "Qual a deusa grega da sabedoria?", OptionA = "Atena", OptionB = "Afrodite", OptionC = "Hera", OptionD = "Artemis", CorrectOption = 'A' },
                new Question { Id = 33, DifficultyLevel = 11, Text = "Que cientista formulou a teoria da relatividade?", OptionA = "Galileu Galilei", OptionB = "Albert Einstein", OptionC = "Niels Bohr", OptionD = "Stephen Hawking", CorrectOption = 'B' },
                // Nível 12
                new Question { Id = 34, DifficultyLevel = 12, Text = "Em que ano ocorreu a queda do Império Romano do Ocidente?", OptionA = "1453", OptionB = "1066", OptionC = "476", OptionD = "395", CorrectOption = 'C' },
                new Question { Id = 35, DifficultyLevel = 12, Text = "Quem pintou \"Guernica\"?", OptionA = "Salvador Dalí", OptionB = "Pablo Picasso", OptionC = "Joan Miró", OptionD = "Claude Monet", CorrectOption = 'B' },
                new Question { Id = 36, DifficultyLevel = 12, Text = "Qual a capital da Austrália?", OptionA = "Sydney", OptionB = "Melbourne", OptionC = "Brisbane", OptionD = "Camberra", CorrectOption = 'D' },
                // Perguntas Ronda Bónus (Nível 0, 26 perguntas)
                new Question { Id = 37, DifficultyLevel = 0, Text = "O Sol é uma estrela?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'A' },
                new Question { Id = 38, DifficultyLevel = 0, Text = "A água ferve a 50 graus Celsius?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'B' },
                new Question { Id = 39, DifficultyLevel = 0, Text = "Marte é conhecido como o Planeta Vermelho?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'A' },
                new Question { Id = 40, DifficultyLevel = 0, Text = "O elefante é o maior animal terrestre?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'A' },
                new Question { Id = 41, DifficultyLevel = 0, Text = "O tubarão é um mamífero?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'B' },
                new Question { Id = 42, DifficultyLevel = 0, Text = "A Terra é plana?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'B' },
                new Question { Id = 43, DifficultyLevel = 0, Text = "O ouro tem símbolo químico Au?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'A' },
                new Question { Id = 44, DifficultyLevel = 0, Text = "A lua é um satélite natural?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'A' },
                new Question { Id = 45, DifficultyLevel = 0, Text = "O morcego é uma ave?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'B' },
                new Question { Id = 46, DifficultyLevel = 0, Text = "Os humanos têm 3 pulmões?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'B' },
                new Question { Id = 47, DifficultyLevel = 0, Text = "O diamante é feito de carbono?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'A' },
                new Question { Id = 48, DifficultyLevel = 0, Text = "O gelo afunda na água?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'B' },
                new Question { Id = 49, DifficultyLevel = 0, Text = "O Brasil é na América do Sul?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'A' },
                new Question { Id = 50, DifficultyLevel = 0, Text = "A baleia é um peixe?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'B' },
                new Question { Id = 51, DifficultyLevel = 0, Text = "O tomate é um vegetal?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'B' },
                new Question { Id = 52, DifficultyLevel = 0, Text = "O sangue humano é azul no interior das veias?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'B' },
                new Question { Id = 53, DifficultyLevel = 0, Text = "As aranhas são insetos?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'B' },
                new Question { Id = 54, DifficultyLevel = 0, Text = "A capital do Japão é Tóquio?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'A' },
                new Question { Id = 55, DifficultyLevel = 0, Text = "A luz viaja mais rápido que o som?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'A' },
                new Question { Id = 56, DifficultyLevel = 0, Text = "Os cangurus vivem naturalmente no Brasil?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'B' },
                new Question { Id = 57, DifficultyLevel = 0, Text = "A fórmula da água é H2O?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'A' },
                new Question { Id = 58, DifficultyLevel = 0, Text = "O pinguim sabe voar?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'B' },
                new Question { Id = 59, DifficultyLevel = 0, Text = "Júpiter tem anéis?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'A' },
                new Question { Id = 60, DifficultyLevel = 0, Text = "O Everest é a montanha mais alta do mundo?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'A' },
                new Question { Id = 61, DifficultyLevel = 0, Text = "Os dinossauros foram extintos por um vírus?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'B' },
                new Question { Id = 62, DifficultyLevel = 0, Text = "A Torre Eiffel fica em Londres?", OptionA = "Verdadeiro", OptionB = "Falso", OptionC = null, OptionD = null, CorrectOption = 'B' }
            );
        }
    }
}
