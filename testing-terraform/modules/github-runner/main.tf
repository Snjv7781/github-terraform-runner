resource "google_compute_instance" "github-runner" {
  name         = "github-runner"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-2404-lts-amd64"
    }
  }

  network_interface {
    subnetwork = var.subnet
    # No access_config block = no external IP, use Cloud NAT for outbound internet
  }

  tags = ["github-runner"]

  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -e
    exec > /var/log/startup-script.log 2>&1

    # Create 'runner' user if not exists
    id -u runner &>/dev/null || useradd -m runner
    mkdir -p /home/runner/actions-runner
    chown -R runner:runner /home/runner

    # Install dependencies
    apt-get update
    apt-get install -y curl jq git sudo

    # Download and extract GitHub Actions Runner as 'runner' user
    RUNNER_VERSION="${var.runner_version}"
    su - runner -c "cd /home/runner/actions-runner && curl -LO https://github.com/actions/runner/releases/download/v$${RUNNER_VERSION}/actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz"
    su - runner -c "cd /home/runner/actions-runner && tar xzf actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz"

    # Configure the runner
    GITHUB_URL="${var.github_repo_url}"
    RUNNER_TOKEN="${var.runner_token}"

    # Retry config.sh up to 5 times in case of token/network issues
    for i in {1..5}; do
      su - runner -c "cd /home/runner/actions-runner && ./config.sh --unattended --url $${GITHUB_URL} --token $${RUNNER_TOKEN} --name gcp-runner --work _work --replace" && break
      echo "config.sh failed, retrying in 10 seconds..."
      sleep 10
    done

    # Create systemd service for the runner
    cat <<EOF > /etc/systemd/system/github-runner.service
    [Unit]
    Description=GitHub Actions Runner
    After=network.target

    [Service]
    ExecStart=/home/runner/actions-runner/run.sh
    User=runner
    WorkingDirectory=/home/runner/actions-runner
    Restart=always

    [Install]
    WantedBy=multi-user.target
    EOF

    systemctl daemon-reload
    systemctl enable github-runner
    systemctl start github-runner
  EOT
}