using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Joker.API.Migrations
{
    /// <inheritdoc />
    public partial class SeedQuestions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Questions",
                columns: new[] { "Id", "CorrectOption", "DifficultyLevel", "OptionA", "OptionB", "OptionC", "OptionD", "Text" },
                values: new object[,]
                {
                    { 1, "C", 1, "Porto", "Faro", "Lisboa", "Coimbra", "Qual é a capital de Portugal?" },
                    { 2, "B", 1, "Duas", "Três", "Quatro", "Cinco", "Quantas cores tem a bandeira portuguesa?" },
                    { 3, "B", 1, "Tejo", "Douro", "Minho", "Guadiana", "Que rio desagua na cidade do Porto?" },
                    { 4, "A", 2, "Júpiter", "Marte", "Terra", "Saturno", "Qual é o maior planeta do sistema solar?" },
                    { 5, "C", 2, "364", "365", "366", "367", "Quantos dias tem um ano bissexto?" },
                    { 6, "D", 2, "Fernando Pessoa", "José Saramago", "Eça de Queirós", "Luís de Camões", "Quem escreveu \"Os Lusíadas\"?" },
                    { 7, "B", 3, "Prata", "Ouro", "Ferro", "Cobre", "Qual o metal cujo símbolo químico é Au?" },
                    { 8, "A", 3, "África", "Ásia", "Europa", "América", "Em que continente fica o Egipto?" },
                    { 9, "C", 3, "Índico", "Pacífico", "Atlântico", "Ártico", "Qual é o oceano que banha a costa de Portugal?" },
                    { 10, "B", 4, "Oito", "Dez", "Doze", "Nove", "Quantos cantos têm \"Os Lusíadas\"?" },
                    { 11, "C", 4, "D. Sancho I", "D. Dinis", "D. Afonso Henriques", "D. João I", "Qual foi o primeiro rei de Portugal?" },
                    { 12, "B", 4, "1972", "1974", "1975", "1976", "Em que ano se deu o 25 de Abril?" },
                    { 13, "D", 5, "Tíbia", "Rádio", "Úmero", "Fémur", "Qual o osso mais longo do corpo humano?" },
                    { 14, "A", 5, "Gepardo", "Leão", "Tigre", "Gazela", "Qual o animal terrestre mais rápido?" },
                    { 15, "B", 5, "Picasso", "Leonardo da Vinci", "Van Gogh", "Dalí", "Quem pintou a Mona Lisa?" },
                    { 16, "C", 6, "The Beatles", "Rolling Stones", "Queen", "Pink Floyd", "De que banda era vocalista Freddie Mercury?" },
                    { 17, "A", 6, "Mandarim", "Espanhol", "Inglês", "Hindi", "Qual a língua nativa mais falada no mundo?" },
                    { 18, "D", 6, "Inglaterra", "Espanha", "Itália", "França", "Que país ofereceu a Estátua da Liberdade aos EUA?" },
                    { 19, "B", 7, "Gobi", "Sara", "Atacama", "Kalahari", "Qual é o deserto mais quente do mundo?" },
                    { 20, "A", 7, "Neil Armstrong", "Yuri Gagarin", "Buzz Aldrin", "Michael Collins", "Quem foi o primeiro homem a pisar a lua?" },
                    { 21, "C", 7, "Mónaco", "San Marino", "Vaticano", "Liechtenstein", "Qual é o menor país do mundo?" },
                    { 22, "B", 8, "1943", "1945", "1947", "1950", "Em que ano terminou a Segunda Guerra Mundial?" },
                    { 23, "C", 8, "Oxigénio", "Carbono", "Hidrogénio", "Hélio", "Qual o elemento mais abundante no universo?" },
                    { 24, "A", 8, "Thomas Edison", "Nikola Tesla", "Alexander Bell", "Albert Einstein", "Qual o nome do inventor da lâmpada elétrica comercial?" },
                    { 25, "B", 9, "Steven Spielberg", "Francis Ford Coppola", "Martin Scorsese", "Quentin Tarantino", "Quem realizou o filme \"O Padrinho\"?" },
                    { 26, "D", 9, "O2", "CO2", "H2O", "O3", "Qual a fórmula química do ozono?" },
                    { 27, "C", 9, "Brasil", "Argentina", "Uruguai", "Itália", "Que país venceu o primeiro mundial de futebol em 1930?" },
                    { 28, "A", 10, "Tordesilhas", "Versalhes", "Madrid", "Paris", "Qual o tratado que dividiu o mundo novo entre Portugal e Espanha?" },
                    { 29, "B", 10, "Os Lusíadas", "Dom Quixote", "Hamlet", "A Divina Comédia", "Qual a obra mais famosa de Miguel de Cervantes?" },
                    { 30, "D", 10, "Ácido cítrico", "Ácido sulfúrico", "Ácido clorídrico", "Ácido acético", "Qual o ácido presente no vinagre?" },
                    { 31, "C", 11, "Marie Curie", "Louis Pasteur", "Alexander Fleming", "Isaac Newton", "Quem descobriu a penicilina?" },
                    { 32, "A", 11, "Atena", "Afrodite", "Hera", "Artemis", "Qual a deusa grega da sabedoria?" },
                    { 33, "B", 11, "Galileu Galilei", "Albert Einstein", "Niels Bohr", "Stephen Hawking", "Que cientista formulou a teoria da relatividade?" },
                    { 34, "C", 12, "1453", "1066", "476", "395", "Em que ano ocorreu a queda do Império Romano do Ocidente?" },
                    { 35, "B", 12, "Salvador Dalí", "Pablo Picasso", "Joan Miró", "Claude Monet", "Quem pintou \"Guernica\"?" },
                    { 36, "D", 12, "Sydney", "Melbourne", "Brisbane", "Camberra", "Qual a capital da Austrália?" }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 20);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 21);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 22);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 23);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 24);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 25);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 26);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 27);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 28);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 29);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 30);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 31);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 32);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 33);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 34);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 35);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 36);
        }
    }
}
