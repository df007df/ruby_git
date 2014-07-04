def getProjPath(proj) 
    PROJ_PATH + Env.getProjDomain(proj, 'www') + '/'
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

    Env.mg('config ok!')
end    


def getMigration_limit_version(proj, ssh)

    path = getProjPath(proj)
    
    if Env.createUser?
        command = "cd #{path}migrations; ls  | sort -d | sed -n '$p' | awk -F'_' '{print $1}'"       
        ssh.exec! command
    else 
        ''
    end    

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

        'MiGRATION_LIMIT_VERSION' => getMigration_limit_version(proj, ssh).strip

    }

    configs = replaceString(mainPath, configs);


    addMainPath = path + 'config/development/app.php'

    ssh.exec "echo \"#{configs}\" > #{addMainPath}"

     Env.mg('app config ok!')
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

    Env.mg('assets config ok!')
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

    Env.mg('database config ok!')
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
    ssh.exec! "echo \"#{configs}\" > #{addMainPath}"

    Env.mg('queue config ok!')
end  






def chmodFile(proj, ssh)

    uploadPath = getProjPath(proj) + 'upload/'
    logPath = getProjPath(proj) + 'log'

    ssh.exec "mkdir -p #{uploadPath} && chmod 777 #{uploadPath}"
    ssh.exec! "chmod 777 #{logPath}"

    Env.mg('upload ok!')

end 


def composer(proj, ssh)
    #ln -s
    path = getProjPath(proj)
    ssh.exec!("cp -R #{COMPOSER_PATH} #{path} && echo 1")

    Env.mg('composer cp ok!')
end 



def checkPhpmig(proj, ssh)
    path = getProjPath(proj)
    status = ssh.exec!("[ -f '#{path}script/phpmig.php' ] && echo 1")
    if status
        status.strip
    end    
    
end

def migrate(proj, ssh)
    
    if !Env.phpmigMigrate?
        path = getProjPath(proj)
        while checkPhpmig(proj, ssh) == '1'
            command = "cd #{path}; ./script/phpmig.php migrate"
            ssh.exec command
            Env.mg('migrate ok!')
            break
        end

        
    end    
end 


def initData(proj, ssh)
    
    if Env.phpmigInit?
        path = getProjPath(proj)
        while checkPhpmig(proj, ssh) == '1'
            ssh.exec "cd #{path}; ./script/phpmig.php up init && ./script/phpmig.php up initdata"

            Env.mg('database init and initdata ok!')
            break
        end


        version = getMigration_limit_version(proj, ssh).strip
        command = "cd #{path}; ./deploy/phpmig_up #{version}"
        ssh.exec command
        
    end 

end 


def copyFileIo(proj, ssh)

end 


def startQueue(proj, ssh)
    path = getProjPath(proj)
    command = "cd #{path}; sudo ./deploy/resque restart"
    ssh.exec command
    Env.mg('queue ok!')
end 



def iniCrontab(proj, ssh)
    path = getProjPath(proj)
    command = "cd #{path}; ./deploy/crontab"
    ssh.exec command
    Env.mg('crontab ok!')
end 



def initGit(proj, ssh) 
	path = getProjPath(proj)   

    newbarch = Env.getBranch(proj)

    ssh.exec! "sudo mkdir -p #{path} && sudo chown #{PROJ_USER}:#{PROJ_USER} #{path}"
    ssh.exec! "git init #{path} && git --git-dir=#{path}/.git checkout -b master"
    ssh.exec! "git config -f #{path}.git/config receive.denyCurrentBranch ignore"
    config = ssh.exec! "git config --get -f #{path}.git/config receive.denyCurrentBranch"
    if /ignore/iu =~ config
        Env.mg 'git init ok!'
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


def delProjPath(proj, ssh)

    path = getProjPath(proj)
    ssh.exec "sudo rm -R #{path}"

    Env.mg 'projpath del is ok!'
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



def delNginx(proj, ssh)
    nginxPath = PROJ_NGINX_PATH
    server_name = Env.getProjDomain(proj, :www)

    newPath = nginxPath + 'sites-available/' + server_name
    enaPath = nginxPath + 'sites-enabled/' + server_name

    ssh.exec "sudo rm #{newPath} && sudo rm #{enaPath}"

    Env.mg 'nginx del is ok!' 

end    

    
    def addDb(proj, ssh)
        dbname = Env.getProjDomainDbName(proj)
        command = "mysql --user='#{DB_USER}' --password='#{DB_PWD}' -e'CREATE DATABASE IF NOT EXISTS #{dbname};' "
        ssh.exec(command)
        Env.mg 'db createDb ok!' 
    end


    def addDbUser(proj, ssh)


        if Env.createDb?
            addDb(proj, ssh)
        end


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

            commandTmp = "echo \"#{sql}\" > #{tmpSql}"
            command = "mysql --user='#{DB_USER}' --password='#{DB_PWD}' < #{tmpSql}"

            ssh.exec(commandTmp + ' && ' + command)

            Env.mg 'db adduser ok!' 
        end

    end



     


    def delDb(proj, ssh)




    end    



    def delDbUser(proj, ssh)    
        dbconfig = PATH + 'config/deldb.sql'
        str = {
            'dbuser' => Env.getDbUserName(proj),
            'host' =>  'localhost',
            'dbname' => Env.getProjDomainDbName(proj),
        }

        sql = replaceString(dbconfig, str);

        tmpSql = "/tmp/#{proj}_delsql" 

        commandTmp = "echo \"#{sql}\" > #{tmpSql}"
        command = "mysql --user='#{DB_USER}' --password='#{DB_PWD}' < #{tmpSql}"

        ssh.exec(commandTmp + ' && ' + command)
        Env.mg 'db+user del is ok!' 
    end    
