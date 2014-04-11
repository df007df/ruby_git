def getProjPath(proj) 
    PROJ_PATH + Env.getProjDomain(proj) + '/'
end




def devConfig(proj, ssh)
    path = getProjPath(proj)

    mainPath = PATH + 'config/main.php'
    configs = {
        'APP_NAME' => Env.getAppName(proj),
        'ROOT_DOMAIN' => Env.getProjDomain(proj).sub('www.', ''),

        'WWW_DOMAIN' => Env.getProjDomain(proj),
        'STATIC_DOMAIN' => Env.getProjDomain(proj, 'static'),
        'FILEIO_DOMAIN' => Env.getProjDomain(proj, 'fileio'),

        'PORT' => HOST_PORT,

        'M_S' => 'localhost',
        'M_S_P' => '11211',

        'S_T' => 'master',

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

def initData(proj, ssh)
    Dir.chdir(getProjPath(proj))
    p `pwd`
    `ENV=production ./script/phpming.php migrate`
end 


def copyFileIo(proj, ssh)

end 




def initGit(proj, ssh) 
	path = getProjPath(proj)   

    newbarch = Env.getBranch(proj)

    ssh.exec "sudo mkdir -p #{path}"
	ssh.exec "sudo chown #{PROJ_USER}:#{PROJ_USER} #{path}"

    config = ssh.exec! "git config --get -f #{path}.git/config receive.denyCurrentBranch"
    
    if /ignore/iu =~ config
    	puts 'git init ok!'
    else
        ssh.exec "cd #{path}; git init #{path} && git checkout -b  #{newbarch} && git remote rm origin || git branch -D master"
        ssh.exec "cd #{path}; git config -f #{path}.git/config receive.denyCurrentBranch ignore"

        if /ignore/iu =~ config
            puts 'git init ok!'
        else
            Env.exit 'git init error config!'
        end

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
        'server_name' => Env.getProjDomain(proj),
        'server_port' => HOST_PORT,
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

    puts ssh.exec "sudo echo '#{string}' > #{tmpfile} && sudo chown root:root #{tmpfile} && sudo chmod 644  #{tmpfile} && sudo mv #{tmpfile} #{newPath} && sudo ln -s #{newPath}  #{enaPath}"

    puts ssh.exec "sudo service nginx restart"

end 



def addDbUser(proj, ssh)

    if Env.createUser?
        dbconfig = PATH + 'config/user.sql'
        str = {
            'dbuser' => getDbUserName(proj),
            'password' => getDbPwd(proj),
            'host' =>  'localhost',
            'dbname' => Env.getProjDomainDbName(proj),
        }

        sql = replaceString(dbconfig, str);

        tmpSql = "/tmp/#{proj}_sql"

        puts ssh.exec "echo '#{sql}' > #{tmpSql} && mysql --user=#{DB_USER} --password=#{DB_PWD} < #{tmpSql}"

    end    
    

end 