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
	pushProj = "sudo su git -c 'git push #{barnch} #{barnch}:#{barnch}'"

          
	 if !checkRemote(barnch, ssh)
	 	ssh.exec "cd #{BARE_PATH}; #{addremote}"
	
	 	moveHeads(Setting.get('copybranch'), barnch, ssh);

	 	ssh.exec "cd #{BARE_PATH}; #{pushProj}"
	 else
	 	Env.exit "#{barnch} remote is exists"	
	 end	

end	


def moveHeads(proj, newproj, ssh)
	headsPath = 'refs/heads/'

	projH = "#{BARE_PATH}#{headsPath}#{proj}"
	newprojH = "#{BARE_PATH}#{headsPath}#{newproj}"
	ssh.exec "sudo su git -c 'cp #{projH} #{newprojH}'"
end



