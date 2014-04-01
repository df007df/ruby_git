def checkRemote(barnch, ssh) 
	barnchs = ssh.exec!("cd #{BARE_PATH}; git remote")
	if barnchs == nil || barnchs.split(/\n/).select{|line|  line.index(barnch)}.empty?
		false
	else
		true
	end	
end	


def checkBranch(barnch, ssh) 
	barnchs = ssh.exec!("cd #{BARE_PATH}; git branch")
	if barnchs == nil || barnchs.split(/\n/).select{|line|  line.index(barnch)}.empty?
		false
	else
		true
	end	
end


def addProjRemote(proj, ssh)
	#need ssh login  gem net-ssh 
	projpath = getProjPath(proj)
	barnch = Env.getBranch(proj)
	addremote = "git remote add #{barnch} #{PROJ_USER}@#{PROJ_HOST}:#{projpath}"
	pushProj = "git push #{barnch} #{barnch}:#{barnch}"
        
  
          
	 if !checkRemote(barnch, ssh)
	 	puts ssh.exec "cd #{BARE_PATH}; #{addremote}"
	 	#copyBranch(barnch, COPY_BRANCH, ssh)
	 	#puts ssh.exec "cd #{BARE_PATH}; #{pushProj}"
	 else
	 	puts "#{barnch} remote is exists"	
	 end	

end	



