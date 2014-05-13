#!/user/bin/ruby
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'pathname'
require 'net/ssh'
require 'multi_json'
require 'slop'
require 'json'


require 'model/depository'
require 'model/remote'
require 'model/setting'
require 'model/env'



PATH = Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/'





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



def startMemcached(proj)
	path = PATH + 'tools/memcache/start.rb'
	puts `ruby #{path}`
end	



 def checkoutConfigBranch() 
 	#in config dir
 	Dir.chdir(CONFIG_BRANCH_PATH)

 	`git fetch`
 	
 	#git checkout proj/tt
 	barnchs = `git branch`
	if barnchs == nil || barnchs.split(/\n/).select{|line|  line.index(barnch)}.empty?
		puts 'config not find  proj branch'
	else
	
		`git checkout #{getBranch(proj)}`		
	end
	
 end	
 	





opts = Slop.parse do
  on '-v', 'Print the version' do
    puts "Version 1.0"
  end
  on 'c=', 'config json'
end

if !opts[:c] || opts[:c].empty?
	Env.exit 'config error'
end

Setting.load opts[:c]


Env.type = Setting.get 'type'
proj = Setting.get('branch')

if proj.empty?
	Env.exit 'branch error'
end	


require 'config'

Env.mg 'push is start!'




loginSSH(PROJ_HOST, PROJ_USER, PROJ_PASS) {|ssh| 
  	initGit(proj, ssh)

  	Env.pp 10
}


	
loginSSH(PROJ_HOST, PROJ_USER, PROJ_PASS) {|ssh| 
  	cPostUpdate(proj, ssh)

  	Env.pp 10
}


	
loginSSH(BARE_HOST, BARE_USER, BARE_PASS) {|ssh| 
  	addProjRemote(proj, ssh)

  	Env.pp 10
}



loginSSH(PROJ_HOST, PROJ_USER, PROJ_PASS) {|ssh| 
  	buildNginx(proj, ssh)
  	Env.pp 10
}



loginSSH(PROJ_HOST, PROJ_USER, PROJ_PASS) {|ssh| 
  	addDbUser(proj, ssh)
  	Env.pp 10
}



loginSSH(PROJ_HOST, PROJ_USER, PROJ_PASS) {|ssh| 
  	
	Env.process(proj, ssh)

	Env.mg 'all is ok!'

		
}

