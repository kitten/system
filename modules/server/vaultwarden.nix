{ ... }:

{
  services.vaultwarden = {
    enable = true;
    dbBackend = "sqlite";
    config = {
      IP_HEADER = "X-Real-IP";
      ADMIN_TOKEN = "$argon2id$v=19$m=65540,t=3,p=4$+5A5H6YiN6OxyrFggkrft8Mm+sxgh/tL3USbaYFZ/h8$qj8NjE+COL4WXjmjkPWSQk7iLfhaBfBtV6k06Bql3CQ";
      PASSWORD_HINTS_ALLOWED = "false";
      SIGNUPS_ALLOWED = "false";
      DOMAIN = "https://cola.fable-pancake.ts.net";
      WEBSOCKET_ADDRESS = "127.0.0.1";
      ROCKET_ADDRESS = "127.0.0.1";
      WEBSOCKET_PORT = "8001";
      ROCKET_PORT = "8000";
      ROCKET_LIMITS = "{json=10485760}";
    };
  };
}
