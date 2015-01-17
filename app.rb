require 'sinatra'
require 'json'
require 'digest'
require 'literate_randomizer'
require "sinatra/reloader" if development?

set :port, 8000

get '/' do
	#random sample text in addition to texts 0 through 6
	File.open("texts/7", 'w') {|f| f.write(LiterateRandomizer.paragraph)}
	files = %w(texts/0 texts/1 texts/2 texts/3 texts/4 texts/5 texts/6 texts/7)
	text_file = files.sample
	source_text = File.read(text_file).strip
	source_text_purelc = source_text.downcase.gsub(/[^0-9A-Za-z\s]/, '')
	text_array = source_text_purelc.split.uniq

	exclude = []
	if text_array.length > 1
		exclude = text_array.sample(rand(1..text_array.length-1)) 
	end

	hash =  {:text => source_text, :exclude => exclude}
	json = JSON.generate(hash)
	#salted key for json
	key = Digest::SHA2.hexdigest(json+'aliens') 
	hash[:key] = key
	json = JSON.generate(hash)

	erb :"get.json", locals: {json: json}
end

post '/' do
	begin 
		#set checks for media (content) type, json structure, key, and count
		mediacheck = (request.media_type == 'application/json')

		parsed_request = JSON.parse(request.body.read.to_s)
		structurecheck = ['text', 'exclude', 'key', 'count'].all? {|x| parsed_request.key?(x)}
		hash = parsed_request.clone
		['key', 'count'].each {|x| hash.delete(x)}

		validkey = (parsed_request["key"] == Digest::SHA2.hexdigest(JSON.generate(hash)+"aliens"))

		text_array = parsed_request['text'].downcase.gsub(/[^0-9A-Za-z\s]/, '').split
		parsed_request['exclude'].each {|x| text_array.delete(x)}
		counthash = (text_array.inject(Hash.new{0}) {|hash, word| hash[word] += 1; hash })
		parsedcounthash = Hash[parsed_request['count'].map {|k, v| [k.gsub(/[^0-9A-Za-z\s]/, '').downcase, v.to_i] }]

		countcheck = (counthash == parsedcounthash)
		
		if [mediacheck, structurecheck, validkey, countcheck].all? {|x| x == true}
			status 200
			body ''
		else
			raise Exception.new("Alien request detected!")
		end
    rescue Exception => e
	  status 400
	  body ''
	end
end