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

	pushBitBuckent = "sudo su git -c 'git push origin #{barnch}:#{barnch}' "

    	Env.mg 'remote is start!'

	if !checkRemote(barnch, ssh)
	 	ssh.exec "cd #{BARE_PATH}; #{addremote}"
	
	 	moveHeads(Setting.get('copybranch'), barnch, ssh);

	 	puts ssh.exec! "cd #{BARE_PATH}; #{pushProj}; #{pushBitBuckent}"
	else
	 	Env.exit "#{barnch} remote is exists"	
	end	

	Env.mg 'remote is ok!'

end	


def moveHeads(proj, newproj, ssh)
	headsPath = 'refs/heads/'

	projH = "#{BARE_PATH}#{headsPath}#{proj}"
	newprojH = "#{BARE_PATH}#{headsPath}#{newproj}"

	status = ssh.exec!("[ !-f '#{newprojH}' ] && echo 1")
	if status
	    ssh.exec "sudo su git -c 'cp #{projH} #{newprojH}'"	
	end 
end



def delProjRemote(proj, ssh)
	barnch = Env.getBranch(proj)
	delremote = "sudo su git -c 'git remote rm #{barnch}'"
	delBranch = "sudo su git -c 'git branch -D #{barnch}'"

	ssh.exec "cd #{BARE_PATH}; #{delremote}"
	ssh.exec "cd #{BARE_PATH}; #{delBranch}"

	Env.mg 'remote del is ok!'

end


