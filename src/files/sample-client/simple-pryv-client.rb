require 'JSON'
require 'httparty'


Base_url = 'https://jonmaim.rec.la'
Access_token = 'VPygPIwrUJ'


# TODO error checking / handling
class PryvServer
	Url_template = "#{Base_url}/%method_path%?auth=#{Access_token}"

	def initialize
		super
		@http = HTTParty
	end

	def get( path )
		r = @http.get Url_template.gsub('%method_path%', path)
		
		log "response for GET #{path} #{r}"
		r
	end

	def post( path, body = nil )
		r = @http.post(
			Url_template.gsub('%method_path%', path), 
			{ 
				headers: { "Content-Type" => "application/json" }, 
				body: body
			})

		log "response for POST #{path}: #{r.inspect}"
		r
	end

	#=

	##
	# @return channel_id
	def get_or_create( channel_name )
		channels = JSON.parse get('/channels').body

		matching_channels = channels.select{ |c| c['name'] == channel_name }
		if matching_channels.empty?
			# existing channel not found - create one.

			channel = {
				name: channel_name
			}
			response = JSON.parse post('/channels', channel.to_json).body
			channel_id = response['id']
		else
			channel_id = matching_channels[0]['id']
		end

		log "id for channel #{channel_name}: #{channel_id}"

		PryvChannel.new self, channel_id
	end

end

class PryvChannel

	def initialize(server, channel_id)
		@server = server
		@channel_id = channel_id
	end

	def create_event( summary, note )
		event = {
			type: {
				class: "note",
				format: "txt"
			}, 
			value: note
		}

		@server.post "/#{@channel_id}/events", event.to_json
	end

	def events
		r = @server.get "/#{@channel_id}/events"
		JSON.parse r.body
	end

end


def log( msg )
	puts msg
end


## main

server = PryvServer.new
mood_channel = server.get_or_create 'moods_2'

mood_channel.create_event 'Excuberent', 'Just won the lottery. YESSSSSS!'
mood_channel.create_event 'Sad', 'I spent all the money in the casino.'

log mood_channel.events
