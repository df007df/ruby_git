<?php
require __DIR__ . '/main.php';
//Main::\$APPLICATION_NAME = '{{APP_NAME}}';

Main::\$WWW_DOMAIN = '{{WWW_DOMAIN}}';
Main::\$ROOT_DOMAIN = '{{ROOT_DOMAIN}}';
Main::\$STATIC_DOMAIN = '{{STATIC_DOMAIN}}';
Main::\$FILEIO_DOMAIN = '{{FILEIO_DOMAIN}}';

Main::\$MEMCACHE_SERVERS = array(
        array(
            'host'   => '{{M_S}}',
            'port'   => '{{M_S_P}}',
            'weight' => 50,
        )
    );

Main::\$STORAGE_SERVERS = array(
  '{{S_T_HOST}}' => '{{S_T}}'
);

Main::\$REDIS_SERVER   = '{{REDIS_SERVER}}';

Main::\$DATABASE_SERVERS = array(
      array(
          'group'  => 0, // DATABASE GROUP 0
          'rules'  => array(
              '/.+\s.+/ix',        // All tables
         ),
          'master' => array(
              'name'     => '{{D_NAME}}',
              'host'     => '{{D_HOST}}',
              'port'     => 3306,
              'dbname'   => '{{D_DB}}',
              'user'     => '{{D_USER}}',
              'password' => '{{D_PWD}}',
          ),
          'slave'  => array(
              array(
                  'name'     => '{{D_NAME}}',
                  'host'     => '{{D_HOST}}',
                  'port'     => 3306,
                  'dbname'   => '{{D_DB}}',
                  'user'     => '{{D_USER}}',
                  'password' => '{{D_PWD}}',
              ),
          )
      )
  );
