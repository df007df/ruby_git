#!/user/bin/ruby

require 'pathname'


PROJ_HOST = '127.0.0.1'  #248
PROJ_PATH = '/home/df007df/www/'
PROJ_USER = 'df007df'
NGINX_PATH = '/etc/nginx/'

BARE_HOST = '127.0.0.1'
BARE_PATH = '/home/git/benq.git/'


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
		if write.is_a?(Hash)
			buffer = fr.read
			write.each do |index, item|
				buffer = buffer.gsub("{{#{index}}}", item)
			end	
		else	
			buffer = fr.read.sub(Regexp.new(str), write)		
		end	
		#
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

def checkRemote(barnch) 
	Dir.chdir(BARE_PATH)

	barnchs = `git remote`

	if barnchs.split(/\n/).select{|line|  line.index(barnch)}.empty?
		false
	else
		true
	end	
end	

def checkBranch(barnch) 
	Dir.chdir(BARE_PATH)

	barnchs = `git branch`

	if barnchs.split(/\n/).select{|line|  line.index(barnch)}.empty?
		false
	else
		true
	end	
end

def copyBranch(newBarnch, copyBarnch) 

	if checkBranch(copyBarnch)

		if !checkBranch(newBarnch)
			copy = `sudo -u git git branch #{newBarnch} #{copyBarnch}`
			push = `sudo -u git git push #{newBarnch} #{newBarnch}:#{newBarnch}`
		else
			p 'newbranch is exits: ' + newBarnch
			exit
		end		
		
	else
		p 'no copy branch: ' + COPY_BRANCH
		exit
	end	

end	



def addProjRemote(proj)
	#need ssh login  gem net-ssh 

	#bare git path
	projpath = getProjPath(proj)
	barnch = getBranch(proj)
	Dir.chdir(BARE_PATH)

	#git remote add proj/newproj git@192.168.0.248:/var/www/www.newproj.aysaas.com
	addremote = "sudo -u git git remote add #{barnch} #{PROJ_USER}@#{PROJ_HOST}:#{projpath}"

	#check remote
	if !checkRemote(barnch)
		`#{addremote}`
		copyBranch(barnch, COPY_BRANCH)
	else
		p "#{barnch} remote is exists"	
	end	


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


def setMain() 

	config = {
		'proj' => ,
		'domain' => ,
		'cookie_domain' => ,
		'static_domain' => ,
		'fileio_domain' => ,
		'port_memcache' => ,
		'dbname' => ,
		'dbuser' => ,
		'dbpassword' => 
	}



end	






proj = 'df'

buildWeb(proj)

=begin
	
projpath = getProjPath(proj)
initGit(projpath)
cPostUpdate(proj)

addProjRemote(proj)

buildWeb(proj)

=end