CREATE USER '{{dbuser}}'@'{{host}}' IDENTIFIED BY '{{password}}';
GRANT USAGE ON * . * TO '{{dbuser}}'@'{{host}}' IDENTIFIED BY '{{password}}' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0 ;
#CREATE DATABASE IF NOT EXISTS \`{{dbname}}\`;
GRANT ALL PRIVILEGES ON \`{{dbname}}\` . * TO '{{dbuser}}'@'{{host}}';