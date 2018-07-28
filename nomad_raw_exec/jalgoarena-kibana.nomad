job "jalgoarena-kibana" {
  datacenters = ["dc1"]

  type = "system"

  update {
    max_parallel = 1
    healthy_deadline = "3m"
  }

  group "kibana-docker" {

    ephemeral_disk {
      size = 1000
    }

    task "kibana" {
      driver = "raw_exec"

      artifact {
        source  = "https://artifacts.elastic.co/downloads/kibana/kibana-6.3.2-darwin-x86_64.tar.gz"
      }

      config {
        command = "local/bin/kibana"
      }

      resources {
        cpu    = 500
        memory = 500
        network {
          port "kibana" {
            static = 5601
          }
        }
      }

      service {
        name = "kibana"
        tags = ["elk", "traefik.enable=false"]
        port = "kibana"
        check {
          type      = "tcp"
          interval  = "10s"
          timeout   = "1s"
        }
      }

      template {
        data = <<EOH
ELASTICSEARCH_URL = "http://{{ range $index, $elasticsearch := service "elasticsearch" }}{{ if eq $index 0 }}{{ $elasticsearch.Address }}:{{ $elasticsearch.Port }}{{ end }}{{ end }}"
EOH

        destination = "local/config.env"
        env         = true
      }
    }
  }
}
