<?php


return array(



    'database_servers'  => array(
         array(
            'group' => 0, // DATABASE GROUP 0
            'rules' => array(
            '/.+\s`.+`/ix',        // All system tables
            ),
            'master' => array(
                'name' => '{{D_NAME}}',
                'host' => '{{D_HOST}}',
                'port' => 3306,
                'dbname' => '{{D_DB}}',
                'user' => '{{D_USER}}',
                'password' => '{{D_PWD}}',
            ),
            'slave' => array(
                array(
                    'name' => '{{D_NAME}}',
                    'host' => '{{D_HOST}}',
                    'port' => 3306,
                    'dbname' => '{{D_DB}}',
                    'user' => '{{D_USER}}',
                    'password' => '{{D_PWD}}',
                ),
            ),
        ),
    ),


    'model_path' => MODPATH.'dao'


);