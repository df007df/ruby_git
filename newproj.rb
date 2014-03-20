#!/user/bin/ruby
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'pathname'
require 'net/ssh'
require 'multi_json'
require 'config'

require 'model/depository'
require 'model/local'
require 'model/remote'


PATH = Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/'

#p Dir.getwd

#Dir.chdir('/home')
#p `pwd`
#p Dir.getwd


def getProjDomain (proj, pex = nil)
	if pex
		"#{pex}.test.#{proj}.aysaas.com"
	else
		"www.test.#{proj}.aysaas.com"	
	end	
		
end	


def getProjDomainDbName (proj, pex = nil)
	if pex
		"#{pex}_test_#{proj}_aysaas_com"
	else
		"www_test_#{proj}_aysaas_com"	
	end	
		
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








############# bare-git host

def loginSSH(host, user, password)
	Net::SSH.start( host, user, :password => password ) do |ssh|
	   yield ssh	
	end
end	



def copyBranch(newBarnch, copyBarnch, ssh) 

	if checkBranch(copyBarnch, ssh)

		if !checkBranch(newBarnch, ssh)
			cddir = "cd #{BARE_PATH};"
			copy = ssh.exec!("#{cddir} git branch #{newBarnch} #{copyBarnch}")
			puts copy
		else
			puts 'newbranch is exits: ' + newBarnch
			exit
		end		
		
	else
		p 'no copy branch: ' + COPY_BRANCH
		exit
	end	

end	







################  bulidWEB  ##################



def startMemcached(proj)
	path = PATH + 'tools/memcache/start.rb'
	puts `ruby #{path}`
end	






	




def getAppName(proj)
	'AYSaaS-' + proj
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





############## checkout config path, add&push config

 def checkoutConfigBranch() 
 	#in config dir
 	Dir.chdir(CONFIG_BRANCH_PATH)
 	
 	#git fetch 
 	`git fetch`
 	
 	#git checkout proj/tt
 	barnchs = `git branch`
	if barnchs == nil || barnchs.split(/\n/).select{|line|  line.index(barnch)}.empty?
		puts 'config not find  proj branch'
	else
		
		`git checkout #{getBranch(proj)}`
		 #edit config
		 
		 
		 
 	
 		#git push
		
	end
 	
 	
 	
 
 	
 	
 		
 end	
 	



proj = PROJ

=begin

loginSSH(BARE_HOST, BARE_USER, BARE_PASS) {|ssh| 
  	addProjRemote(proj, ssh);
}

loginSSH(PROJ_HOST, PROJ_USER, PROJ_PASS) {|ssh| 
  	initGit(proj, ssh);
}

loginSSH(PROJ_HOST, PROJ_USER, PROJ_PASS) {|ssh| 
  	cPostUpdate(proj, ssh);
}




loginSSH(PROJ_HOST, PROJ_USER, PROJ_PASS) {|ssh| 
  	buildNginx(proj, ssh);
}



loginSSH(PROJ_HOST, PROJ_USER, PROJ_PASS) {|ssh| 
  	addDbUser(proj, ssh);
}

=end


Local.setMain(proj);



=begin
 initGit(proj) #ok
  cPostUpdate(proj) #ok

  loginSSH(BARE_HOST, BARE_USER, BARE_PASS){|ssh| 
  	addProjRemote(proj, ssh);
 }



addDbUser(proj)  #ok



startMemcached(proj); #ok


setMain(proj)
chmodFile(proj)
#initData(proj)

=end