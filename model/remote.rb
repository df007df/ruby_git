def getProjPath(proj) 
    PROJ_PATH + getProjDomain(proj) + '/'
end


def initGit(proj, ssh) 
	path = getProjPath(proj)

    puts ssh.exec "sudo mkdir #{path}"
	puts ssh.exec "sudo chown #{PROJ_USER}:#{PROJ_USER} #{path}"


    puts ssh.exec "cd #{path} & git init #{path} & git remote rm origin & git branch -D master"


	puts ssh.exec "cd #{path} & git config -f #{path}.git/config receive.denyCurrentBranch ignore"
    
    config = ssh.exec! "cd #{path} & git config --get -f #{path}.git/config receive.denyCurrentBranch"
   
     if /ignore/iu =~ config
     	puts 'git init ok!'
     else
     	puts 'git init error config!'
     end


end






def cPostUpdate(proj, ssh) 

    path = getProjPath(proj)
    exampath = PATH + 'config/post-update'
    string = replaceString(exampath, proj, '{{proj}}')

    hookPath = path + '.git/hooks/post-update';

    puts ssh.exec "echo '#{string}' > #{hookPath} & sudo chown #{PROJ_USER}:#{PROJ_USER} #{hookPath} & sudo chmod 751  #{hookPath}"
end 




def buildNginx(proj, ssh)

    nginxPath = PROJ_NGINX_PATH
    projPublicPath = getProjPath(proj) + 'public'

    str = {
        'server_name' => getProjDomain(proj),
        'server_port' => HOST_PORT,
        'root' => projPublicPath,
        'log_path' =>  '/var/log/nginx/',
        'static_name' => getProjDomain(proj, :static),
        'fileio_name' => getProjDomain(proj, :fileio),
        'env' => 'development'
    }

    config_nginx_file = PATH + 'config/nginx-server'

    string = replaceString(config_nginx_file, str)
    tmpfile = '/tmp/' + str['server_name']
    newPath = nginxPath + 'sites-available/' + str['server_name']
    enaPath = nginxPath + 'sites-enabled/' + str['server_name']

    puts ssh.exec "sudo echo '#{string}' > #{tmpfile} & sudo chown root:root #{tmpfile} & sudo chmod 644  #{tmpfile} & sudo mv #{tmpfile} #{newPath} & sudo ln -s #{newPath}  #{enaPath}"


end 



def getDbUserName(proj)
    'saas_' + proj
end 

def getDbPwd(proj)
    '123456'
end 

def addDbUser(proj, ssh)
    dbconfig = PATH + 'config/user.sql'
    str = {
        'dbuser' => getDbUserName(proj),
        'password' => getDbPwd(proj),
        'host' =>  'localhost',
        'dbname' => getProjDomainDbName(proj),
    }

    sql = replaceString(dbconfig, str);

    tmpSql = "/tmp/#{proj}_sql"

    puts ssh.exec "echo '#{sql}' > #{tmpSql} & mysql --user=#{DB_USER} --password=#{DB_PWD} < #{tmpSql}"

end 