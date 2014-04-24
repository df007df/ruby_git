class Setting

	@@setting = ''

	def self.load(config)



		@@setting = config
	end

	def self.get(key)

		config = JSON.parse(@@setting)

		if !key.include? key
			Env.exit "config:#{key} error"
		end	

		config[key]

	end	


end	