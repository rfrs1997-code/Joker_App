using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using Joker.API.Data;
using Joker.API.DTOs;
using Joker.API.Models;

namespace Joker.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;

        public AuthController(AppDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromForm] RegisterDto request)
        {
            // 1. Validação de campos vazios (Adicionámos o request.Email)
            if (string.IsNullOrWhiteSpace(request.Username) || 
                string.IsNullOrWhiteSpace(request.Password) || 
                string.IsNullOrWhiteSpace(request.Email))
            {
                return BadRequest("Nome de utilizador, e-mail e palavra-passe são obrigatórios.");
            }

            // 2. Validação do formato do E-mail
            // Utiliza a classe nativa do .NET para garantir que é um email válido (ex: teste@teste.com)
            if (!new System.ComponentModel.DataAnnotations.EmailAddressAttribute().IsValid(request.Email))
            {
                return BadRequest("O formato do e-mail fornecido é inválido.");
            }

            // 3. Validar se o utilizador ou email já existem (O teu código original)
            if (await _context.Users.AnyAsync(u => u.Username == request.Username))
                return BadRequest("Este nome de utilizador já está em uso.");

            if (await _context.Users.AnyAsync(u => u.Email == request.Email))
                return BadRequest("Este e-mail já está registado.");

            // Encriptar a palavra-passe
            string passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);

            string profilePicturePath = string.Empty;
            if (request.ProfilePicture != null && request.ProfilePicture.Length > 0)
            {
                profilePicturePath = request.ProfilePicture.FileName;
            }

            var user = new User
            {
                Name = request.Name,
                Username = request.Username,
                Email = request.Email,
                PasswordHash = passwordHash,
                ProfilePicture = profilePicturePath
            };

            try
            {
                _context.Users.Add(user);
                await _context.SaveChangesAsync();
                return Ok(new { Message = "Registo efetuado com sucesso!" });
            }
            catch (DbUpdateException dbEx)
            {
                // Este catch apanha erros específicos de SQL (triggers, constraints, nulls)
                var realError = dbEx.InnerException != null ? dbEx.InnerException.Message : dbEx.Message;
                return StatusCode(500, $"Erro de Base de Dados: {realError}");
            }
            catch (Exception ex)
            {
                // Apanha qualquer outro erro inesperado
                return StatusCode(500, $"Erro Crítico: {ex.Message}");
            }
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login(LoginDto request)
        {
            // Procurar o utilizador
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == request.Username);
            
            // Tratamento de erro: Credenciais inválidas
            if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            {
                return Unauthorized("Credenciais inválidas.");
            }

            // Gerar JWT para a sessão persistente
            string token = CreateToken(user);

            return Ok(new { Token = token, Username = user.Username });
        }

        [HttpGet("profiles")]
        public async Task<IActionResult> GetAllProfiles()
        {
            // Procura todos os utilizadores na BD através do teu ApplicationDbContext
            var users = await _context.Users
                .Select(u => new {
                    u.Id,
                    u.Name,
                    u.Username,
                    u.Email,
                    u.ProfilePicture // Envia o caminho da foto para o Flutter renderizar
                })
                .ToListAsync();

    return Ok(users);
}

        // Método auxiliar para gerar o token JWT
        private string CreateToken(User user)
        {
            List<Claim> claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Name, user.Username)
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(
                _configuration.GetSection("AppSettings:Token").Value!));

            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha512Signature);

            var token = new JwtSecurityToken(
                claims: claims,
                expires: DateTime.Now.AddDays(7), // Token válido por 7 dias
                signingCredentials: creds
            );

            var jwt = new JwtSecurityTokenHandler().WriteToken(token);
            return jwt;
        }
    }
}
