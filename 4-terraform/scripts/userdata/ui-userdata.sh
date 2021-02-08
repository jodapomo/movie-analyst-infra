#!/bin/bash
export repository_url="${repository_url}"
export repo_name="${repo_name}"
export app_port="${app_port}"
export api_url="${api_url}"
export user="${user}"

git clone https://github.com/jodapomo/movie-analyst-infra.git
init_script="/movie-analyst-infra/3-aws/userdata/ui-userdata.sh"
chmod +x $init_script
$init_script
rm -rf /movie-analyst-infra