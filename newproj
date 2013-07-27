#!/user/bin/ruby

require 'pathname'


PROJ_HOST = '127.0.0.1'  #248
PROJ_PATH = '/home/df007df/www/'
PROJ_USER = 'df007df'

BARE_HOST = '127.0.0.1'
BARE_PATH = '/home/git/benq.git/'



PATH = Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/'

#p Dir.getwd

#Dir.chdir('/home')
#p `pwd`
#p Dir.getwd


def getProjDomain (proj)
	"www.#{proj}.aysaas.com/"
end	

def getProjPath(proj) 
	PROJ_PATH + getProjDomain(proj)
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





def replaceString(file, write, str)
	buffer = ''
	File.open(file) do |fr|
		buffer = fr.read.sub(Regexp.new(str), write)
	end
	buffer	
end	



def cPostUpdate(proj) 

	projpath = getProjPath(proj)
	exampath = PATH + 'config/post-update'
	string = replaceString(exampath, proj, '{{proj}}')

	newPath = projpath + '.git/hooks/post-update';

	`sudo echo '#{string}' > #{newPath} `
	`sudo chown git:git #{newPath}`
	`sudo chmod 751  #{newPath}`
	#File.open(newPath, 'w') {|fw| fw.write(string)}


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

	barnchs = `git remote`

	if barnchs.split(/\n/).select{|line|  /#{line}/iu =~ barnch}.empty?
		`#{addremote}`
	else
		p "#{barnch} is exists"	
	end	

	

		

	

end	



proj = 'oa'

projpath = getProjPath(proj)
initGit(projpath)
cPostUpdate(proj)

addProjRemote(proj)