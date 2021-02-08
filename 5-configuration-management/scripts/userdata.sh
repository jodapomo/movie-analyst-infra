#!/bin/bash
export api_port="${jenkins_port}"
export user="${user}"
export compose_file_path="/movie-analyst-infra/5-configuration-management/scripts/docker-compose.yml"

git clone https://github.com/jodapomo/movie-analyst-infra.git
init_script="/movie-analyst-infra/5-configuration-management/scripts/launch.sh"
chmod +x $init_script
$init_script
rm -rf /movie-analyst-infra
