#!/user/bin/ruby

require 'pathname'
require 'net/ssh'
require 'multi_json'

PROJ_HOST = '127.0.0.1'  #248
PROJ_PATH = '/home/df007df/www/'
PROJ_USER = 'df007df'
NGINX_PATH = '/etc/nginx/'

DB_USER = 'root'
DB_PWD  = '123456'


BARE_HOST = '127.0.0.1'
BARE_PATH = '/home/git/benq.git/'
BARE_USER = 'git'
BARE_PASS = '123456'

COPY_BRANCH = 'master'



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


def initGit(path) 
	if !File.exists?path
    	`sudo mkdir #{path}`
    end	
	puts `sudo chown #{PROJ_USER} #{path}`

	#puts path
    `cd '#{path}'`

	`sudo -u #{PROJ_USER} git init #{path}`
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
		buffer = fr.read
		if write.is_a?(Hash)			
			write.each do |index, item|
				buffer = buffer.gsub("{{#{index}}}", item.to_s)
			end	
		else	
			buffer = fr.read.gsub(Regexp.new(str), write)		
		end
	end
	buffer	
end	



def cPostUpdate(proj) 

	projpath = getProjPath(proj)
	exampath = PATH + 'config/post-update'
	string = replaceString(exampath, proj, '{{proj}}')

	newPath = projpath + '.git/hooks/post-update';

	if `sudo echo '#{string}' > #{newPath}`
		`sudo chown git:#{PROJ_USER} #{newPath}`
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
	if barnchs.split(/\n/).select{|line|  line.index(barnch)}.empty?
		false
	else
		true
	end	
end	

def checkBranch(barnch, ssh) 
	barnchs = ssh.exec!("cd #{BARE_PATH}; git branch")
	if barnchs.split(/\n/).select{|line|  line.index(barnch)}.empty?
		false
	else
		true
	end	
end

def copyBranch(newBarnch, copyBarnch, ssh) 

	if checkBranch(copyBarnch, ssh)

		if !checkBranch(newBarnch, ssh)
			cddir = "cd #{BARE_PATH};"
			copy = ssh.exec!("#{cddir} git branch #{newBarnch} #{copyBarnch}")
			push = ssh.exec!("#{cddir} git push #{newBarnch} #{newBarnch}:#{newBarnch}")

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

	 if !checkRemote(barnch, ssh)
	 	ssh.exec "cd #{BARE_PATH}; #{addremote}"
	 	copyBranch(barnch, COPY_BRANCH, ssh)
	 else
	 	p "#{barnch} remote is exists"	
	 end	

end	





################  bulidWEB  ##################




def addMemcached(proj) 
	confFile = PATH + 'tools/memcache/config'
	File.open(confFile) do |fr|
		hosts = fr.read
		lasthost = ''
		if hosts.split(/\n/).select{|line| lasthost = line; line =~ /^#{proj}/ }.empty?
			port = lasthost.split(':')[1].to_i + 1
			port = port < 11212 ? 11212 : port
			`echo "#{proj}:#{port}" >> #{confFile}`
		end
	end
	
end	


def startMemcached(proj)
	path = PATH + 'tools/memcache/start.rb'
	puts `ruby #{path}`
end	




def buildWeb(proj)

	projPath = getProjPath(proj)

	str = {
	    'server_name' => getProjDomain(proj),
		'root' => projPath,
		'log_path' =>  '/var/log/nginx/',
		'static_name' => getProjDomain(proj, :static)
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

def addDbUser(proj)
	dbconfig = PATH + 'config/user.sql'
	str = {
	    'dbuser' => getDbUserName(proj),
		'password' => '123456',
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

	memcache = [{'host' => '192.168.0.231', 'port' => 11211 , 'weight' => 50}]

	storage = {'192.168.0.231' => 'd1'}

	database = [{'group' => '0', 'rules' => '/.+s`.+`/ix' , 'master' => {
		'name' => 'root',
		'host' => 'localhost',
		'dbname' => 'www.oa.aysaas.com',
		'user' => 'root',
		'password' => '123456',
		} 

	}]


	configs = {
		'APP_NAME' => getAppName(proj),
		'ROOT_DOMAIN' => getProjDomain(proj).sub('www.', ''),

		'MEMCACHE' => MultiJson.dump(memcache),
		'STORAGE' => MultiJson.dump(storage),
		'DATABASE' => MultiJson.dump(database)
	}

	configs = replaceString(mainPath, configs);

	tmp_main = PATH + 'tmp_main.php'

	`echo #{configs} > #{tmp_main}`

	#puts configs


end	


def toArray()


end	



proj = 'aahh'


setMain(proj)

#addDbUser(proj)

#addMemcached(proj)
#startMemcached(proj);

# projpath = getProjPath(proj)
# initGit(projpath)
# cPostUpdate(proj)

# loginSSH(BARE_HOST, BARE_USER, BARE_PASS){|ssh| 
# 	addProjRemote(proj, ssh);
# 	ssh.loop
# }

#buildWeb(proj)