using Joker.API.Data;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// 1. Adicionar o serviço de Controladores (essencial para as rotas da API)
builder.Services.AddControllers();

// 2. Configurar o Gerador do Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
    {
        options.SwaggerDoc("v1", new OpenApiInfo { Title = "Joker API", Version = "v1" });
        
        // Configuração extra útil: Permite-te colar o Token JWT diretamente no Swagger para testar o jogo!
        options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
        {
            In = ParameterLocation.Header,
            Description = "Por favor introduza o token JWT com o prefixo 'Bearer ' (Exemplo: Bearer eyJhbG...)",
            Name = "Authorization",
            Type = SecuritySchemeType.ApiKey,
            BearerFormat = "JWT",
            Scheme = "Bearer"
        });

        options.AddSecurityRequirement(new OpenApiSecurityRequirement
        {
            {
                new OpenApiSecurityScheme
                {
                    Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
                },
                Array.Empty<string>()
            }
        });
    });

// 3. Configurar a Ligação ao SQL Server
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// 4. Configurar a Autenticação por Tokens JWT
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(
                builder.Configuration.GetSection("AppSettings:Token").Value!)),
            ValidateIssuer = false,
            ValidateAudience = false
        };
    });

var app = builder.Build();

// 5. ATIVAR O SWAGGER NO PIPELINE (O que estava em falta para a página não ficar em branco)
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Joker API v1");
        c.RoutePrefix = "swagger"; // Garante que a rota é exatamente localhost:5219/swagger
    });
}

// 6. Configurar a ordem de execução de segurança do servidor
app.UseRouting();

app.UseAuthentication(); // Primeiro autentica (quem és tu?)
app.UseAuthorization();  // Depois autoriza (o que podes fazer?)

app.MapControllers();    // Mapeia os teus controladores (Auth e Game)

app.Run();