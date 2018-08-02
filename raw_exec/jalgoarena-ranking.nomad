job "jalgoarena-ranking" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    healthy_deadline = "3m"
  }

  group "jalgoarena-ranking" {
    count = 2

    task "jalgoarena-ranking" {
      driver = "raw_exec"

      artifact {
        source  = "https://github.com/jalgoarena/JAlgoArena-Ranking/releases/download/v2.4.4/JAlgoArena-Ranking-2.4.67.zip"
      }

      config {
        command = "java"
        args = [
          "-Xmx400m", "-Xms50m",
          "-jar", "local/jalgoarena-ranking-2.4.67.jar"
        ]
      }

      resources {
        cpu    = 1000
        memory = 512
        network {
          port "http" {}
        }
      }

      env {
        PORT = "${NOMAD_PORT_http}"
      }

      service {
        name = "jalgoarena-ranking"
        tags = ["traefik.frontend.rule=PathPrefixStrip:/ranking/api", "secure=false"]
        port = "http"
        check {
          type          = "http"
          path          = "/actuator/health"
          interval      = "10s"
          timeout       = "1s"
        }
      }

      template {
        data = <<EOH
JALGOARENA_API_URL = "http://{{ range $index, $traefik := service "traefik" }}{{ if eq $index 0 }}{{ $traefik.Address }}:{{ $traefik.Port }}{{ end }}{{ end }}"
{{ range $index, $cockroach := service "cockroach" }}{{ if eq $index 0 }}
DB_HOST = "{{ $cockroach.Address }}"
DB_PORT = "{{ $cockroach.Port }}"
{{ end }}{{ end }}
EOH

        destination = "local/config.env"
        env         = true
      }
    }
  }
}