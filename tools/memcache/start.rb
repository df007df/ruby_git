#!/user/bin/ruby

require 'pathname'
confFile = 'config'
PATH = Pathname.new(File.dirname(__FILE__)).realpath.to_s + '/'


File.open(PATH + confFile) do |fr|
	buffer = fr.read
	buffer.each_line do |item|
		info = item.split(':')		
	 	query = "ps -aef | grep memcached | grep -v 'grep' | grep #{info[1]} "
	 	if `#{query}` != ''
	 		puts info[0] + ' is running'
	 	else
	 		#start = `memcached -d -p '#{info[1].to_i}' -l "127.0.0.1" -u "memcache"`
	 		puts info[0] + ' memcached is restart!!'
	 	end	

	end	

end



#

