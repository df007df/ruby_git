<?php
/**
 * Main configurations class file
 *
 * @Copyright (C) 2011 Safirst Technology (www.a-y.com.cn)
 */

/**
 * Main configurations class
 */
class Main
{
    static $APPLICATION_NAME   = 'AYSaaS-{{proj}}';

    const  IS_DEBUG           = false;

    const  IS_SOLR            = false;

    // 指定时间到达以后，计划任务模块会调用各应用模块的 schedule 方法去执行任务。
    // 对应用模块 schedule 方法的访问是由机器的 crontab 进行的，因此需要 SKIP_IDENTITY。
    static $SKIP_IDENTITY = false;

    // 60*60*24*15 = 1296000 seconds = 15 days
    const  SESSION_EXPIRY_RME = 1296000;

    static $IS_IP = false;

    static $ROOT_DOMAIN = '{{domain}}';

    static $COOKIE_DOMAIN = '{{cookie_domain}}';

    static $STATIC_DOMAIN = '{{static_domain}}';

    static $FILEIO_DOMAIN = '{{fileio_domain}}';

    const  EMAIL_SENDER = '安元科技·业务基础平台 <anyuanproject@gmail.com>';

    static $SMTP_PARAMS = array(
        'host' => 'smtp.gmail.com',
        'port' => '587', // Backup port: 465
        'auth' => true,
        'username' => 'anyuanproject@gmail.com',
        'password' => 'AnYuan.Project.for.Redmine',
        // 'timeout'  => 3,
    );

    const TASK_EMAIL = 'webmaster@aysaas.com'; // 系统错误通知邮件地址

    const VISUAL_ICON_DIR = 'visual/images/nodeIcon/'; // 热点图标（系统）目录


    static $MEMCACHE_SERVERS = array(
        array(
            'host'   => 'localhost', // localhost
            'port'   => '{{port_memcache}}',
            'weight' => 100,
        ),
    );

    static $STORAGE_SERVERS   = array(
        '192.168.0.70' => '{{proj}}' // localhost
    );

    static $DATABASE_SERVERS  = array(
        array(
            'group'  => 0, // DATABASE GROUP 0
            'rules'  => array(
                '/.+\s`.+`/ix',        // All tables
            ),
            'master' => array(
                'name'     => 'localhost',
                'host'     => 'localhost',
                'port'     => 3306,
                'dbname'   => '{{dbname}}',
                'user'     => '{{dbuser}}',
                'password' => '{{dbpassword}}'
            ),
            'slave' => array(
                array(
                    'name'     => 'localhost',
                    'host'     => 'localhost',
                    'port'     => 3306,
                    'dbname'   => '{{dbname}}',
                    'user'     => '{{dbuser}}',
                    'password' => '{{dbpassword}}'
                ),
            ),
        ),
    );

    static $CLASS_MAP = array(
        // apps
        'LibStore' => 'model/libstore.php',
        'LibVisual' => 'model/libvisual.php',
        'LibWorkflow' => 'model/libworkflow.php',

        // foundation
        'libAppManager' => 'model/libappmanager.php',
        'LibCommunication' => 'model/libcommunication.php',
        'LibEnterprise' => 'model/libenterprise.php',
        'LibForm' => 'model/libform.php',
        'LibMenu' => 'model/libmenu.php',
        'LibPermission' => 'model/libpermission.php',
        'LibSysConfig' => 'model/libsysconfig.php',
        'LibUser' => 'model/libuser.php',

        // framework
        'Dbio' => 'framework/base/dbio.php',
        'Debug' => 'framework/base/debug.php',
        'Fileio' => 'framework/base/fileio.php',
        'Session' => 'framework/base/session.php',
        'CMemCacheServerConfiguration' => 'framework/cache/cmemcacheserverconfiguration.php',
        'Mcache' => 'framework/cache/mcache.php',
        'Schema' => 'framework/schema/schema.php',
        'Api' => 'framework/schema/api.php',
        'Controller' => 'framework/schema/controller.php',
        'Email' => 'framework/utils/email.php',
        'Pinyin' => 'framework/utils/pinyin.php',
        'Scheduler' => 'framework/utils/scheduler.php',
        'Error' => 'framework/web/error.php',
        'Html' => 'framework/web/html.php',
        'Mustache' => 'framework/web/mustache.php',
        'Page' => 'framework/web/page.php',
        'Validate' => 'framework/web/validate.php',

        'In' => 'framework/base/in.php',
        'LibInfo' => 'model/libinfo.php',
        'Hook' => 'framework/hook/hook.php',
        'Sms' => 'framework/base/sms.php',
        'Solr' => 'framework/solr/solr.php',

        //规则引擎
        'PluginManager' => 'framework/enginerules/base/pluginmanager.php',
        'TimerManager' => 'framework/enginerules/base/timermanager.php',
        'ScriptManager' => 'framework/enginerules/base/scriptmanager.php',

        'LibArticle' => 'model/libarticle.php',
        'Weather' => 'framework/base/weather.php'

    );

    static $MENU_OBJ = array(
        '/api/message/menu' => '站内短信',
        '/api/store/menu' => '文档管理'
    );


    /**
     * solr 服务地址
     * @todo 分布!?
     * host:8080/solr
     */
    static $SOLR = array(
        'endpoint' => array(
            's1' => array(
                'host' => '192.168.0.248',
                'port' => 8080,
                'path' => '/solr/core0',
            )
         )
    );

    static $schemaPath; //企业初始化基本数据结构文件路径

    static $loginLockedExpire = 1; //用户多次登录失败后，对该用户锁定的时间（分）

    static $loginTryTimes = 3; //用户尝试登录次数

    static $loginTryTimesExpire = 30; //用户尝试登录次数验证过期时间（分）

    static $tokenSecret = 'f485eea5d3fe11428d96140542749c07%'; //生成token的密钥
}

//规则引擎
Main::$CLASS_MAP['PluginManager'] = 'framework/enginerules/base/pluginmanager.php';
Main::$CLASS_MAP['TimerManager'] = 'framework/enginerules/base/timermanager.php';
Main::$CLASS_MAP['ScriptManager'] = 'framework/enginerules/base/scriptmanager.php';
Main::$schemaPath = __DIR__ . '/../deploy/schema.json';
