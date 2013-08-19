#!/user/bin/ruby
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'pathname'
require 'net/ssh'
require 'multi_json'
require 'config'


PATH = Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/'

#p Dir.getwd

#Dir.chdir('/home')
#p `pwd`
#p Dir.getwd


def getProjDomain (proj, pex = nil)
	if pex
		"#{pex}.#{proj}.aysaas.com"
	else
		"www.#{proj}.aysaas.com"	
	end	
		
end	

def getProjPath(proj) 
	PROJ_PATH + getProjDomain(proj) + '/'
end

def getBranch(proj)
	'proj/' + proj
end	



def getOldProj(proj)

	if proj == 'safirst'
		PROJ_PATH + 'oa.a-y.com.cn/'
	else	
		PROJ_PATH + getProjDomain(proj) + '/'
	end	

end	

def initGit(proj) 
	path = getProjPath(proj)
	if !File.exists?path
    	`sudo mkdir #{path}`
    end	
	puts `sudo chown #{PROJ_USER} #{path}`

	#puts path
    `cd '#{path}'`

	`sudo -u #{PROJ_USER} git init #{path}`

	rmOrigin = "sudo -u #{PROJ_USER} git remote rm origin" #del clone remote
	delBranch = "sudo -u #{PROJ_USER} git branch -D "

	`sudo -u #{PROJ_USER} git config -f #{path}.git/config receive.denyCurrentBranch ignore`
    
    config = `sudo -u #{PROJ_USER} git config --get -f #{path}.git/config receive.denyCurrentBranch`
   
     if /ignore/iu =~ config
     	puts 'git init ok!'
     else
     	puts 'git init error config!'
     end	

end





def replaceString(file, write, str = nil)
	buffer = ''
	File.open(file) do |fr|
		buffer = fr.read.to_s
		if write.is_a?(Hash)			
			write.each do |index, item|
				buffer.gsub!(/\{\{#{index}\}\}/, item.to_s)
			end	
		else	
			buffer.gsub!(Regexp.new(str), write)		
		end
	end
	buffer	
end	



def cPostUpdate(proj) 

	projpath = getProjPath(proj)
	exampath = PATH + 'config/post-update'
	string = replaceString(exampath, proj, '{{proj}}')

	newPath = projpath + '.git/hooks/post-update';

	if `echo '#{string}' > #{newPath}`
		`sudo chown #{PROJ_USER}:#{PROJ_USER} #{newPath}`
		`sudo chmod 751  #{newPath}`	
	end	
	
	
	#File.open(newPath, 'w') {|fw| fw.write(string)}


end	







############# bare-git host

def loginSSH(host, user, password)
	Net::SSH.start( host, user, :password => password ) do |ssh|
	   yield ssh	
	end
end	



def checkRemote(barnch, ssh) 
	barnchs = ssh.exec!("cd #{BARE_PATH}; git remote")
	if barnchs == nil || barnchs.split(/\n/).select{|line|  line.index(barnch)}.empty?
		false
	else
		true
	end	
end	

def checkBranch(barnch, ssh) 
	barnchs = ssh.exec!("sudo su git; cd #{BARE_PATH}; git branch")
	if barnchs == nil || barnchs.split(/\n/).select{|line|  line.index(barnch)}.empty?
		false
	else
		true
	end	
end

def copyBranch(newBarnch, copyBarnch, ssh) 

	if checkBranch(copyBarnch, ssh)

		if !checkBranch(newBarnch, ssh)
			cddir = "cd #{BARE_PATH};"
			copy = ssh.exec!("sudo su git; #{cddir} git branch #{newBarnch} #{copyBarnch}")
		else
			p 'newbranch is exits: ' + newBarnch
			exit
		end		
		
	else
		p 'no copy branch: ' + COPY_BRANCH
		exit
	end	

end	



def addProjRemote(proj, ssh)
	#need ssh login  gem net-ssh 
	projpath = getProjPath(proj)
	barnch = getBranch(proj)
	addremote = "git remote add #{barnch} #{PROJ_USER}@#{PROJ_HOST}:#{projpath}"
	pushProj = "git push #{barnch} #{barnch}:#{barnch}"

	 if !checkRemote(barnch, ssh)
	 	ssh.exec "sudo su git; cd #{BARE_PATH}; #{addremote}"
	 	copyBranch(barnch, COPY_BRANCH, ssh)
	 	ssh.exec "sudo su git; cd #{BARE_PATH}; #{pushProj}"

	 else
	 	p "#{barnch} remote is exists"	
	 end	

end	





################  bulidWEB  ##################




def addMemcached(proj) 
	confFile = PATH + 'tools/memcache/config'
	port = 0
	File.open(confFile) do |fr|
		hosts = fr.read
		lasthost = ''
		proj_host = hosts.split(/\n/).select{|line| lasthost = line; line =~ /^#{proj}/ }
		if proj_host.empty?
			port = lasthost.split(':')[1].to_i + 1
			port = port < 11212 ? 11212 : port
			`echo "#{proj}:#{port}" >> #{confFile}`
		else
			port = proj_host[0].split(':')[1].to_i
		end
	end
	port
end	


def startMemcached(proj)
	path = PATH + 'tools/memcache/start.rb'
	puts `ruby #{path}`
end	




def buildWeb(proj)

	projPublicPath = getProjPath(proj) + 'public'

	str = {
	    'server_name' => getProjDomain(proj),
		'root' => projPublicPath,
		'log_path' =>  '/var/log/nginx/',
		'static_name' => getProjDomain(proj, :static),
		'fileio_name' => getProjDomain(proj, :fileio)
	}

	config_nginx_file = PATH + 'config/nginx-server'

	string = replaceString(config_nginx_file, str)
	tmpfile = PATH + str['server_name']
	newPath = NGINX_PATH + 'sites-available/' + str['server_name']
	enaPath = NGINX_PATH + 'sites-enabled/' + str['server_name']

	if `sudo echo '#{string}' > #{tmpfile}`
		`sudo chown root:root #{tmpfile}`
		`sudo chmod 644  #{tmpfile}`	
		`sudo mv #{tmpfile} #{newPath}`
		`sudo ln -s #{newPath}  #{enaPath}`
	end	

end	

	

def getDbUserName(proj)
	'AySaas_' + proj
end	

def getDbPwd(proj)
	'123456'
end	

def addDbUser(proj)
	dbconfig = PATH + 'config/user.sql'
	str = {
	    'dbuser' => getDbUserName(proj),
		'password' => getDbPwd(proj),
		'host' =>  'localhost',
		'dbname' => getProjDomain(proj),
	}

	sql = replaceString(dbconfig, str);

	tmpfile = PATH + 'tmp_user.sql'
	`echo "#{sql}" > #{tmpfile}`
	puts `mysql --user=#{DB_USER} --password=#{DB_PWD} < #{tmpfile}`
	`rm #{tmpfile}`
end	


def getAppName(proj)
	'AYSaaS-' + proj
end	

def setMain(proj) 
	addMainPath = getProjPath(proj) + 'config/config_main.php'

	mainPath = PATH + 'config/main.php'
	configs = {
		'APP_NAME' => getAppName(proj),
		'ROOT_DOMAIN' => getProjDomain(proj).sub('www.', ''),
		'M_S' => '192.168.0.231',
		'M_S_P' => addMemcached(proj),

		'S_T' => proj,

		'D_NAME' => 'localhost',
		'D_HOST' => '127.0.0.1',
		'D_DB' => getProjDomain(proj),
		'D_USER' => getDbUserName(proj),
		'D_PWD' => getDbPwd(proj)
	}
	configs = replaceString(mainPath, configs);

	tmp_main = PATH + 'tmp_main.php'
	`echo "#{configs}" > #{addMainPath}`
end	




#######  end ############

def chmodFile(proj)
	uploadPath = getProjPath(proj) + 'upload/'
	logPath = getProjPath(proj) + 'log'
	`sudo mkdir #{uploadPath}`
	`sudo chmod 666 #{uploadPath}`
	`sudo chmod 666 #{logPath}`
end	


def composer()
	#ln -s

end	


def initData(proj)
	Dir.chdir(getProjPath(proj))
	p `pwd`
	`ENV=production ./script/phpming.php migrate`
end	

def copyFileIo

end	






proj = 'ts'

 initGit(proj) #ok
  cPostUpdate(proj) #ok

  loginSSH(BARE_HOST, BARE_USER, BARE_PASS){|ssh| 
  	addProjRemote(proj, ssh);
 }

buildWeb(proj)   #ok

addDbUser(proj)  #ok
addMemcached(proj) #ok
startMemcached(proj); #ok


setMain(proj)
chmodFile(proj)
#initData(proj)

