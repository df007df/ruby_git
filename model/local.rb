class Local

	def self.setMain(proj) 
		#addMainPath = getProjPath(proj) + 'config/config_main.php'
		newbarnch = getBranch(proj)

		self.copyBranch(newbarnch, COPY_BRANCH)

		puts `cd #{WORK_PATH}; git checkout #{newbarnch}`



=begin
			
	
		
		mainPath = PATH + 'config/main.php'
		configs = {
			'APP_NAME' => getAppName(proj),
			'ROOT_DOMAIN' => getProjDomain(proj).sub('www.', ''),
			'M_S' => 'localhost',
			'M_S_P' => addMemcached(proj),

			'S_T' => proj,

			'D_NAME' => 'localhost',
			'D_HOST' => '127.0.0.1',
			'D_DB' => getProjDomain(proj),
			'D_USER' => getDbUserName(proj),
			'D_PWD' => getDbPwd(proj)
		}
		configs = replaceString(mainPath, configs);

		tmp_main = PATH + 'tmp_main.php'
		`echo "#{configs}" > #{addMainPath}`

=end

	end	


	def self.copyBranch(newBarnch, copyBarnch) 

		if self.checkBranch(copyBarnch)

			if !self.checkBranch(newBarnch)
				puts `cd #{WORK_PATH}; git branch #{newBarnch} #{copyBarnch}`
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
		barnchs = `cd #{WORK_PATH} & git branch`
		if barnchs == nil || barnchs.split(/\n/).select{|line|  line.index(barnch)}.empty?
			false
		else
			true
		end	
	end

end	





