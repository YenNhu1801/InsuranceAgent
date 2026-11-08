using System.Text.Json.Serialization;

namespace BlazorWasmClient.Components.Auth;

public class AuthResponse
{
    public string Token { get; set; }
    public string UserName { get; set; }
    public string[] Roles { get; set; }
    public string Avatar { get; set; }
    public string UserType { get; set; }

    // AuthService trả về expiryTimeStamp, không phải expiresIn.
    [JsonPropertyName("expiryTimeStamp")]
    public DateTime ExpiresIn { get; set; }
}
