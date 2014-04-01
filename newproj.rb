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



class Env

	@@type = 'release'  #release || proj

	def self.getAppName(proj)
		if @@type == 'release'
			'AYSaaS-release'
		else
			'AYSaaS-proj'	
		end	
		
	end	


	def self.getBranch(proj)
		@@type + '/' + proj
	end	



	def self.getOldProj(proj)

		if proj == 'safirst'
			PROJ_PATH + 'oa.a-y.com.cn/'
		else	
			PROJ_PATH + self.getProjDomain(proj) + '/'
		end	

	end	

	def self._getDomainType()
		return @@type == 'release' ? 'release' : 'test'
	end	

	def self.release?()
		@@type == 'release'
	end	

	def self.proj?()
		@@type == 'proj'
	end	


	def self.createUser?
		!self.release?
	end	


	def self.getCopyBranch
		COPY_BRANCH
	end	


	def self.getProjDomain (proj, pex = nil)

		type = self._getDomainType()
		if pex
			"#{pex}.#{type}.#{proj}.aysaas.com"
		else
			"www.#{type}.#{proj}.aysaas.com"	
		end	
			
	end	

	def self.getProjDomainDbName (proj)

		type = self._getDomainType()

		return type == 'release' ? RELEASE_DB_NAME : "www_#{proj}_aysaas_com"
			
	end	



	def self.getDbUserName(proj)

		return self._getDomainType == 'release' ? RELEASE_DB_USER : 'saas_' + proj

	end 

	def self.getDbPwd(proj)
		return self._getDomainType == 'release' ? RELEASE_DB_PWD : '123456'
	end 



	def self.process(proj, ssh)


		devConfig(proj, ssh)
  		chmodFile(proj, ssh)



		#initData(proj)

		#composer(proj, ssh)
		#copyFileIo(proj, ssh)

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







#######  end ############





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



loginSSH(BARE_HOST, BARE_USER, BARE_PASS) {|ssh| 
  	addProjRemote(proj, ssh)
}

loginSSH(PROJ_HOST, PROJ_USER, PROJ_PASS) {|ssh| 
  	initGit(proj, ssh)
}

loginSSH(PROJ_HOST, PROJ_USER, PROJ_PASS) {|ssh| 
  	cPostUpdate(proj, ssh)
}




loginSSH(PROJ_HOST, PROJ_USER, PROJ_PASS) {|ssh| 
  	buildNginx(proj, ssh)
}



loginSSH(PROJ_HOST, PROJ_USER, PROJ_PASS) {|ssh| 
  	addDbUser(proj, ssh)
}

Local.pushBarnch(proj)




loginSSH(PROJ_HOST, PROJ_USER, PROJ_PASS) {|ssh| 
  	
	Env.process(proj, ssh)

}




=begin

=end