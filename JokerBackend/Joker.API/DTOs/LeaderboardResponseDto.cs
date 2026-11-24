namespace Joker.API.DTOs
{
    public class LeaderboardResponseDto
    {
        public string Username { get; set; } = string.Empty;
        public string ProfilePicture { get; set; } = string.Empty;
        public int HighScore { get; set; }
    }
}
