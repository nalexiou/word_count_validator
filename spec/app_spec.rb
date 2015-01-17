require "./spec/spec_helper"
require "json"
require "digest"

describe 'The Word Counting App' do
  def app
    Sinatra::Application
  end

  describe 'HTTP GET Requests' do
    describe 'Valid GET Requests' do
      before(:each) do
        get '/'
        @lastresponse = last_response
        p @parsed_response = JSON.parse(@lastresponse.body) 
      end

      it "returns 200 and has the right keys" do
        expect(@lastresponse).to be_ok
        expect(@parsed_response).to have_key("text")
        expect(@parsed_response).to have_key("exclude")
        expect(@parsed_response).to have_key("key")
      end

      it "response has correct size of excluded words" do
        if @parsed_response["text"].downcase.gsub(/[^0-9A-Za-z\s]/, '').split.uniq.length > 1
          expect(@parsed_response["exclude"]).not_to be_empty
        else
          expect(@parsed_response["exclude"]).to be_empty
        end
      end

      it "response contains correct key" do
        hash = @parsed_response.clone
        hash.delete("key")
        expect(@parsed_response["key"]).to eq(Digest::SHA2.hexdigest(JSON.generate(hash)+"aliens"))
      end
    end

    describe 'Invalid GET Request' do
      it "invalid GET request" do
        get '/texts'
        expect(last_response).not_to be_ok
      end
    end


  end

  describe 'HTTP POST Requests' do

    describe 'POST Requests using GET response as input ' do
      before(:each) do
        get '/'
        @lastresponse = last_response
        p @parsed_response = JSON.parse(@lastresponse.body) 
        text_array = @parsed_response['text'].downcase.gsub(/[^0-9A-Za-z\s]/, '').split
        @parsed_response['exclude'].each {|x| text_array.delete(x)}
        @counthash = (text_array.inject(Hash.new{0}) {|hash, word| hash[word] += 1; hash })

      end

      it "server returns 200 with valid post request" do
          params = {
          text: @parsed_response["text"],
          exclude: @parsed_response["exclude"],
          key: @parsed_response["key"],
          count: @counthash
          }
        post '/', JSON.generate(params), { 'CONTENT_TYPE' => 'application/json' }
        expect(last_response.status).to eq(200)
      end

      it "server returns 400 with invalid post request key" do
          params = {
          text: @parsed_response["text"],
          exclude: @parsed_response["exclude"],
          key: "somerandominvalidkey",
          count: @counthash
          }
        post '/', JSON.generate(params), { 'CONTENT_TYPE' => 'application/json' }
        expect(last_response.status).to eq(400)
      end

      it "server returns 400 with invalid post request count" do
        params = {
                text: @parsed_response["text"],
                exclude: @parsed_response["exclude"],
                key: @parsed_response["key"],
                count: {random: 1, ran: 4}
              }
        post '/', JSON.generate(params), { 'CONTENT_TYPE' => 'application/json' }
        expect(last_response.status).to eq(400)
      end

    end

    describe 'POST Requests using custom response as input' do

      it "server returns 200 with custom valid post request" do
        params = {
                text: "this is some random text that will test the server",
                exclude: ["this","test"],
                key: "b880393c29c0e170e07f338a27b265eae2d5f484ad75c8e2bde1f8f90fd1149f",
                count: {is: 1, some: 1, random: 1, text: 1, that: 1, will: 1, the: 1, server: 1}
              }
        post '/', JSON.generate(params), { 'CONTENT_TYPE' => 'application/json' }
        expect(last_response.status).to eq(200)
      end

      it "server returns 200 with custom valid post request" do
        params = {
                text: "test Test test test!",
                exclude: [],
                key: "49a6eb537320fd4ca067a80b1c3443c74bae146852fceead59fed6cf8fab11bf",
                count: {test: 4}
              }
        post '/', JSON.generate(params), { 'CONTENT_TYPE' => 'application/json' }
        expect(last_response.status).to eq(200)
      end

        it "server returns 400 with custom invalid content_type" do
        params = {
                text: "test Test test test!",
                exclude: [],
                key: "49a6eb537320fd4ca067a80b1c3443c74bae146852fceead59fed6cf8fab11bf",
                count: {test: 4}
              }
        post '/', JSON.generate(params), { 'CONTENT_TYPE' => 'application/audio' }
        expect(last_response.status).to eq(400)
      end

      it "server returns 400 with custom invalid post request" do
        params = {
                text: "this is some random text that will test the server",
                exclude: ["this","test"],
                key: "b880393c29c0e170e07f338a27b265eae2d5f484ad75c8e2bde1f8f90fd1149f",
                count: {random: 1, ran: 4}
              }
        post '/', JSON.generate(params), { 'CONTENT_TYPE' => 'application/json' }
        expect(last_response.status).to eq(400)
      end 
    end
  end
end