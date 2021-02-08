#!/bin/bash
export repository_url="${repository_url}"
export repo_name="${repo_name}"
export api_port="${api_port}"
export mysql_host="${mysql_host}"
export mysql_port="${mysql_port}"
export mysql_user="${mysql_user}"
export mysql_password="${mysql_password}"
export mysql_db_name="${mysql_db_name}"
export user="${user}"

git clone https://github.com/jodapomo/movie-analyst-infra.git
init_script="/movie-analyst-infra/3-aws/userdata/api-userdata.sh"
chmod +x $init_script
$init_script
rm -rf /movie-analyst-infra