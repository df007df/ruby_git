def getProjPath(proj) 
    PROJ_PATH + Env.getProjDomain(proj, 'www') + '/'
end




def devConfig(proj, ssh)
    path = getProjPath(proj)

    mainPath = PATH + 'config/main.php'
    configs = {
        'APP_NAME' => Env.getAppName(proj),
        'ROOT_DOMAIN' => Env.getProjDomainPort(proj),

        'WWW_DOMAIN' => Env.getProjDomainPort(proj, 'www'),
        'STATIC_DOMAIN' => Env.getProjDomainPort(proj, 'static'),
        'FILEIO_DOMAIN' => Env.getProjDomainPort(proj, 'fileio'),

        'PORT' => HOST_PORT,

        'M_S' => 'localhost',
        'M_S_P' => '11211',

        'S_T' => 'release',

        'S_T_HOST' => Setting.get('proj_host'),

        'REDIS_SERVER' => Setting.get('redis_host'),

        'D_NAME' => 'localhost',
        'D_HOST' => '127.0.0.1',
        'D_DB' => Env.getProjDomainDbName(proj),
        'D_USER' => Env.getDbUserName(proj),
        'D_PWD' => Env.getDbPwd(proj)
    }

    configs = replaceString(mainPath, configs);


    addMainPath = path + 'config/development.php'
    ssh.exec "echo \"#{configs}\" > #{addMainPath}"

end 



def createDev(proj, ssh)
    path = getProjPath(proj)
    ssh.exec! "mkdir -p #{path}config/development"
end    

def devNewConfig(proj, ssh)

    path = getProjPath(proj)
    


    devConfig_app(proj, ssh)
    devConfig_assets(proj, ssh)
    devConfig_database(proj, ssh)
    devConfig_queue(proj, ssh)

end    


def devConfig_app(proj, ssh)
    createDev(proj, ssh)

    path = getProjPath(proj)
    mainPath = PATH + 'config/dev/app.php'

    configs = {
        'APP_NAME' => Env.getAppName(proj),
        'ROOT_DOMAIN' => Env.getProjDomainPort(proj),

        'WWW_DOMAIN' => Env.getProjDomainPort(proj, 'www'),
        'STATIC_DOMAIN' => Env.getProjDomainPort(proj, 'static'),
        'FILEIO_DOMAIN' => Env.getProjDomainPort(proj, 'fileio'),

    }

    configs = replaceString(mainPath, configs);


    addMainPath = path + 'config/development/app.php'

    ssh.exec "echo \"#{configs}\" > #{addMainPath}"

end


def devConfig_assets(proj, ssh)
    createDev(proj, ssh)

    path = getProjPath(proj)
    mainPath = PATH + 'config/dev/assets.php'

    configs = {
        'S_T' => 'release',
        'S_T_HOST' => Setting.get('proj_host'),
    }

    configs = replaceString(mainPath, configs);


    addMainPath = path + 'config/development/assets.php'
    ssh.exec "echo \"#{configs}\" > #{addMainPath}"
end  


def devConfig_database(proj, ssh)
    createDev(proj, ssh)

    path = getProjPath(proj)
    mainPath = PATH + 'config/dev/database.php'

    configs = {
        'D_NAME' => 'localhost',
        'D_HOST' => '127.0.0.1',
        'D_DB' => Env.getProjDomainDbName(proj),
        'D_USER' => Env.getDbUserName(proj),
        'D_PWD' => Env.getDbPwd(proj)

    }

    configs = replaceString(mainPath, configs);


    addMainPath = path + 'config/development/database.php'
    ssh.exec "echo \"#{configs}\" > #{addMainPath}"
end  


def devConfig_queue(proj, ssh)
    createDev(proj, ssh)

    path = getProjPath(proj)
    mainPath = PATH + 'config/dev/queue.php'

    configs = {
        'REDIS_SERVER' => Setting.get('redis_host'),

    }

    configs = replaceString(mainPath, configs);

    addMainPath = path + 'config/development/queue.php'
    ssh.exec "echo \"#{configs}\" > #{addMainPath}"
end  






def chmodFile(proj, ssh)

    uploadPath = getProjPath(proj) + 'upload/'
    logPath = getProjPath(proj) + 'log'

    ssh.exec "mkdir -p #{uploadPath} && chmod 777 #{uploadPath}"
    ssh.exec "chmod 777 #{logPath}"

end 


def composer(proj, ssh)
    #ln -s
    path = getProjPath(proj)
    ssh.exec "cp -R #{COMPOSER_PATH} #{path}"
end 



def checkPhpmig(proj, ssh)
    path = getProjPath(proj)
    ssh.exec!("[ -f '#{path}script/phpmig.php' ] && echo 1")
end

def migrate(proj, ssh)
    
    if !Env.createUser?
        path = getProjPath(proj)


        puts  checkPhpmig(proj, ssh)

        puts '@@'

        while ssh.exec!("[ -f '#{path}script/phpmig.php' ] && echo 1") == '1'
            ssh.exec "ENV=production #{path}script/phpmig.php migrate"
            break
        end

        
    end    
end 


def initData(proj, ssh)
    
    if Env.createUser?

        #`ENV=production ./script/phpming.php migrate`
    end 

end 


def copyFileIo(proj, ssh)

end 




def initGit(proj, ssh) 
	path = getProjPath(proj)   

    newbarch = Env.getBranch(proj)

    ssh.exec! "sudo mkdir -p #{path} && sudo chown #{PROJ_USER}:#{PROJ_USER} #{path}"
    ssh.exec! "git init #{path} && git --git-dir=#{path}/.git checkout -b master"
    ssh.exec! "git config -f #{path}.git/config receive.denyCurrentBranch ignore"
    config = ssh.exec! "git config --get -f #{path}.git/config receive.denyCurrentBranch"
    if /ignore/iu =~ config
        puts 'git init ok!'
    else
        Env.exit 'git init error config!'
    end


end




def cPostUpdate(proj, ssh) 

    path = getProjPath(proj)
    exampath = PATH + 'config/post-update'

    string = replaceString(exampath, Env.getBranch(proj), '{{proj}}')
    
    hookPath = path + '.git/hooks/post-update';

    ssh.exec "echo '#{string}' > #{hookPath} && sudo chown #{PROJ_USER}:#{PROJ_USER} #{hookPath} && sudo chmod 751  #{hookPath}"
end 




def buildNginx(proj, ssh)

    nginxPath = PROJ_NGINX_PATH
    projPublicPath = getProjPath(proj) + 'public'

    str = {
        'server_name' => Env.getProjDomain(proj, :www),
        'server_port' => HOST_PORT ? HOST_PORT : 80,
        'root' => projPublicPath,
        'log_path' =>  '/var/log/nginx/',
        'static_name' => Env.getProjDomain(proj, :static),
        'fileio_name' => Env.getProjDomain(proj, :fileio),
        'env' => 'development'
    }

    config_nginx_file = PATH + 'config/nginx-server'

    string = replaceString(config_nginx_file, str)
    tmpfile = '/tmp/' + str['server_name']
    newPath = nginxPath + 'sites-available/' + str['server_name']
    enaPath = nginxPath + 'sites-enabled/' + str['server_name']

    ssh.exec "sudo echo '#{string}' > #{tmpfile} && sudo chown root:root #{tmpfile} && sudo chmod 644  #{tmpfile} && sudo mv #{tmpfile} #{newPath} && sudo ln -s #{newPath}  #{enaPath}"

    ssh.exec "sudo service nginx restart"

end 



def addDbUser(proj, ssh)

    if Env.createUser?
        dbconfig = PATH + 'config/user.sql'
        str = {
            'dbuser' => Env.getDbUserName(proj),
            'password' => Env.getDbPwd(proj),
            'host' =>  'localhost',
            'dbname' => Env.getProjDomainDbName(proj),
        }

        sql = replaceString(dbconfig, str);

        tmpSql = "/tmp/#{proj}_sql"

        puts ssh.exec "echo '#{sql}' > #{tmpSql} && mysql --user=#{DB_USER} --password=#{DB_PWD} < #{tmpSql}"

    end    
    

end 