{...}: {
  virtualisation.arion = {
    backend = "docker";
    projects.penpot.settings = {
      networks.penpot.name = "penpot";
      services = {
        "penpot-backend".service = {
          image = "penpotapp/backend:latest";
          volumes = ["/penpot_assets:/opt/data/assets"];
          restart = "always";
          depends_on = ["penpot-postgres" "penpot-redis"];
          networks = ["penpot"];
          ports = ["6060:6060"];
          environment = {
            "PENPOT_FLAGS" = "disable-registration enable-login-with-password enable-insecure-register enable-prepl-server";
            "PENPOT_DATABASE_URI" = "postgresql://penpot-postgres/penpot";
            "PENPOT_DATABASE_USERNAME" = "penpot";
            "PENPOT_DATABASE_PASSWORD" = "penpot";
            "PENPOT_REDIS_URI" = "redis://penpot-redis/0";
            "PENPOT_ASSETS_STORAGE_BACKEND" = "assets-fs";
            "PENPOT_STORAGE_ASSETS_FS_DIRECTORY" = "/opt/data/assets";
            "PENPOT_TELEMETRY_ENABLED" = "false";
          };
        };
        "penpot-frontend".service = {
          image = "penpotapp/frontend:latest";
          restart = "always";
          volumes = ["/penpot_assets:/opt/data/assets"];
          depends_on = ["penpot-backend" "penpot-exporter"];
          networks = ["penpot"];
          ports = ["9000:80"];
        };
        "penpot-exporter".service = {
          image = "penpotapp/exporter:latest";
          restart = "always";
          networks = ["penpot"];
          environment = {
            "PENPOT_PUBLIC_URI" = "http://penpot-frontend";
            "PENPOT_REDIS_URI" = "redis://penpot-redis/0";
          };
        };
        "penpot-postgres".service = {
          image = "postgres:15";
          restart = "always";
          stop_signal = "SIGINT";
          volumes = ["/penpot_postgres_v15:/var/lib/postgresql/data"];
          networks = ["penpot"];
          environment = {
            "POSTGRES_INITDB_ARGS" = "--data-checksums";
            "POSTGRES_DB" = "penpot";
            "POSTGRES_USER" = "penpot";
            "POSTGRES_PASSWORD" = "penpot";
          };
        };
        "penpot-redis".service = {
          image = "redis:7";
          restart = "always";
          networks = ["penpot"];
        };
      };
    };
  };
}
