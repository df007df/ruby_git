class Local



	def self.pushBarnch(proj) 
		#addMainPath = getProjPath(proj) + 'config/config_main.php'
		newbarnch = Env.getBranch(proj)	


		if Env.release?

			puts `cd #{WORK_PATH}; git checkout #{newbarnch} -f && git pull origin #{newbarnch}`

		end 

		if Env.proj?
			copyb = Env.getCopyBranch
			self.copyBranch(newbarnch, copyb)
			puts `cd #{WORK_PATH}; git checkout #{newbarnch} -f`

		end	

		
		puts `cd #{WORK_PATH}; git push origin #{newbarnch}:#{newbarnch}`
	
=begin

=end

	end	


	def self.copyBranch(newBarnch, copyBarnch) 

		if self.checkBranch(copyBarnch)

			if !self.checkBranch(newBarnch)
				puts `cd #{WORK_PATH}; git fetch origin #{copyBarnch} && git branch #{newBarnch} #{copyBarnch}`
			else
				puts 'newbranch is exits: ' + newBarnch
				exit
			end		
			
		else
			p 'no copy branch: ' + copyBarnch
			exit
		end	

	end	


	def self.checkBranch(barnch) 
		barnchs = `cd #{WORK_PATH} && git branch`
		if barnchs == nil || barnchs.split(/\n/).select{|line|  line.index(barnch)}.empty?
			false
		else
			true
		end	
	end

end	





