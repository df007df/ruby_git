DROP USER '{{dbuser}}'@'{{host}}';
flush privileges;
drop database {{dbname}};
