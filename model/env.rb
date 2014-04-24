class Env

	@@type = 'release'  #release || proj

	def self.type=(type)
		@@type = type
	end	

	def self.type
		@@type
	end	

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
		@@type 
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
		domain = ''
		if pex
			domain = "#{pex}.#{type}.#{proj}.aysaas.com"
		else
			domain = "www.#{type}.#{proj}.aysaas.com"	
		end	

		HOST_PORT ? domain + ":#{HOST_PORT}" : domain
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

  		composer(proj, ssh)


		#initData(proj)

		#copyFileIo(proj, ssh)

	end	



	def self.pp(n)

		print "|" + '='*n + "| #{n}% \r"
		$stdout.flush
		sleep 1
	end	


	def self.exit(info)
		puts info
		exit! 1
	end	


end	