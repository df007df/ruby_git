require 'time' 

class Env

	@@type = 'release'  #release || proj

	def self.type=(type)
		@@type = type
	end	

	def self.type
		@@type
	end	

	def self.getAppName(proj)
		'AYSaaS-' + proj
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
		(Setting.get('db_createuser') == '1')
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
			domain = "#{type}.#{proj}.aysaas.com"	
		end	
	end	

	def self.getProjDomainPort (proj, pex = nil)

		domain = self.getProjDomain(proj, pex)		
		HOST_PORT ? domain + ":#{HOST_PORT}" : domain
	end

	def self.getProjDomainDbName (proj)
		type = self._getDomainType()

		if self.createUser?
			"#{type}_#{proj}"
		else	
			RELEASE_DB_NAME
		end	
			
	end	



	def self.getDbUserName(proj)

		type = self._getDomainType()
		
		if self.createUser?
			"#{type}_#{proj}"
		else	
			RELEASE_DB_USER
		end	

	end 

	def self.getDbPwd(proj)

		if self.createUser?
			'123456'
		else	
			RELEASE_DB_PWD
		end	

	end 



	def self.process(proj, ssh)


		#devConfig(proj, ssh)
		devNewConfig(proj, ssh)

		composer(proj, ssh)

  		chmodFile(proj, ssh)

		migrate(proj, ssh)

		initData(proj, ssh);

		#copyFileIo(proj, ssh)

	end	



	def self.pp(n)
		sleep 1
	end	


	def self.exit(info)
		puts info
		exit! 1
	end	

	def self.mg(message)

		t = Time.now
		format="%Y-%m-%d %H:%M:%S" 
		p message + " [" + t.strftime(format) + ']'

	end	

end	