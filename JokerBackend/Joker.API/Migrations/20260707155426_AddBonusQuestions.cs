using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Joker.API.Migrations
{
    /// <inheritdoc />
    public partial class AddBonusQuestions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "OptionD",
                table: "Questions",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.AlterColumn<string>(
                name: "OptionC",
                table: "Questions",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.InsertData(
                table: "Questions",
                columns: new[] { "Id", "CorrectOption", "DifficultyLevel", "OptionA", "OptionB", "OptionC", "OptionD", "Text" },
                values: new object[,]
                {
                    { 37, "A", 0, "Verdadeiro", "Falso", null, null, "O Sol é uma estrela?" },
                    { 38, "B", 0, "Verdadeiro", "Falso", null, null, "A água ferve a 50 graus Celsius?" },
                    { 39, "A", 0, "Verdadeiro", "Falso", null, null, "Marte é conhecido como o Planeta Vermelho?" },
                    { 40, "A", 0, "Verdadeiro", "Falso", null, null, "O elefante é o maior animal terrestre?" },
                    { 41, "B", 0, "Verdadeiro", "Falso", null, null, "O tubarão é um mamífero?" },
                    { 42, "B", 0, "Verdadeiro", "Falso", null, null, "A Terra é plana?" },
                    { 43, "A", 0, "Verdadeiro", "Falso", null, null, "O ouro tem símbolo químico Au?" },
                    { 44, "A", 0, "Verdadeiro", "Falso", null, null, "A lua é um satélite natural?" },
                    { 45, "B", 0, "Verdadeiro", "Falso", null, null, "O morcego é uma ave?" },
                    { 46, "B", 0, "Verdadeiro", "Falso", null, null, "Os humanos têm 3 pulmões?" },
                    { 47, "A", 0, "Verdadeiro", "Falso", null, null, "O diamante é feito de carbono?" },
                    { 48, "B", 0, "Verdadeiro", "Falso", null, null, "O gelo afunda na água?" },
                    { 49, "A", 0, "Verdadeiro", "Falso", null, null, "O Brasil é na América do Sul?" },
                    { 50, "B", 0, "Verdadeiro", "Falso", null, null, "A baleia é um peixe?" },
                    { 51, "B", 0, "Verdadeiro", "Falso", null, null, "O tomate é um vegetal?" },
                    { 52, "B", 0, "Verdadeiro", "Falso", null, null, "O sangue humano é azul no interior das veias?" },
                    { 53, "B", 0, "Verdadeiro", "Falso", null, null, "As aranhas são insetos?" },
                    { 54, "A", 0, "Verdadeiro", "Falso", null, null, "A capital do Japão é Tóquio?" },
                    { 55, "A", 0, "Verdadeiro", "Falso", null, null, "A luz viaja mais rápido que o som?" },
                    { 56, "B", 0, "Verdadeiro", "Falso", null, null, "Os cangurus vivem naturalmente no Brasil?" },
                    { 57, "A", 0, "Verdadeiro", "Falso", null, null, "A fórmula da água é H2O?" },
                    { 58, "B", 0, "Verdadeiro", "Falso", null, null, "O pinguim sabe voar?" },
                    { 59, "A", 0, "Verdadeiro", "Falso", null, null, "Júpiter tem anéis?" },
                    { 60, "A", 0, "Verdadeiro", "Falso", null, null, "O Everest é a montanha mais alta do mundo?" },
                    { 61, "B", 0, "Verdadeiro", "Falso", null, null, "Os dinossauros foram extintos por um vírus?" },
                    { 62, "B", 0, "Verdadeiro", "Falso", null, null, "A Torre Eiffel fica em Londres?" }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 37);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 38);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 39);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 40);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 41);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 42);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 43);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 44);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 45);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 46);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 47);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 48);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 49);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 50);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 51);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 52);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 53);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 54);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 55);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 56);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 57);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 58);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 59);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 60);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 61);

            migrationBuilder.DeleteData(
                table: "Questions",
                keyColumn: "Id",
                keyValue: 62);

            migrationBuilder.AlterColumn<string>(
                name: "OptionD",
                table: "Questions",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "OptionC",
                table: "Questions",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);
        }
    }
}
