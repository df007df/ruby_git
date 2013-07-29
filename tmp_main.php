<?php
Main::$APPLICATION_NAME = 'AYSaaS-aahh';
Main::$ROOT_DOMAIN = 'aahh.aysaas.com';

Main::$MEMCACHE_SERVERS = array(
        array(
            'host'   => '192.168.0.231',
            'port'   => '11216',
            'weight' => 50,
        )
    );

Main::$STORAGE_SERVERS = array(
        '192.168.0.248' => 'aahh'
    );


Main::$DATABASE_SERVERS = array(
      array(
          'group'  => 0, // DATABASE GROUP 0
          'rules'  => array(
              '/.+\s.+/ix',        // All tables
         ),
          'master' => array(
              'name'     => 'localhost',
              'host'     => '127.0.0.1',
              'port'     => 3306,
              'dbname'   => 'www.aahh.aysaas.com',
              'user'     => 'AySaas_aahh',
              'password' => '123456',
          ),
          'slave'  => array(
              array(
                  'name'     => 'localhost',
                  'host'     => '127.0.0.1',
                  'port'     => 3306,
                  'dbname'   => 'www.aahh.aysaas.com',
                  'user'     => 'AySaas_aahh',
                  'password' => '123456',
              ),
          )
      )
  );

