require File.dirname(__FILE__) + '/spec_helper'

describe 'main' do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  it 'should check for empty database' do
    get '/pets/'
    last_response.status.should == 200
  end

  # attempt to create invalid pets
  it 'should fail - invalid email' do
    post '/pet', { :email => "test.com", :name=>"Mike", :level=>1 }
    last_response.status.should == 412
  end

  it 'should fail - missing email' do
    post '/pet', { :name=>"Mike", :level=>1 }
    last_response.status.should == 412
  end

  it 'should fail - missing name' do
    post '/pet', {:email=>"riza@zinkus.com", :level=>1 }
    last_response.status.should == 412
  end

  it 'should fail - missing level' do
    post '/pet', {:email=>"riza@zinkus.com", :name=>"Robin"}
    last_response.status.should == 412
  end

  it 'should return API Key' do
    post '/pet', {:email=>"riza@zinkus.com", :name=>"Robin", :level=>1}
    last_response.status.should == 201
    # apikey is 12 chars
    last_response.body.length.should == 12
    $apiKey = last_response.body
  end

  ## Pet successfully created. Now test attributes.

  # attempt with invalid key
  it 'should return 404 - no such key' do
    get '/pet/1234/cleanliness'
    last_response.status.should == 404
  end

  # check default values
  it 'should return cleanliness 75' do
    get "/pet/#{$apiKey}/cleanliness/"
    last_response.status.should == 200
    last_response.body.should == "75"
  end

  it 'should return hunger 75' do
    get "/pet/#{$apiKey}/hunger/"
    last_response.status.should == 200
    last_response.body.should == "75"
  end

  it 'should return mood 93' do
    get "/pet/#{$apiKey}/mood/"
    last_response.status.should == 200
    last_response.body.should == "93"
  end

  ## Simulate interacting with pet

  ## test authorization - need matching key and email address

  # feed the pet

  it 'should return feed updated' do
    post "/pet/#{$apiKey}/feed/", {:email=>"riza@zinkus.com"}
    last_response.status.should == 202
  end

  it 'should return feed unauthorized (incorrect email)' do
    post "/pet/#{$apiKey}/feed/", {:email=>"thisIs@Incorrect.com"}
    last_response.status.should == 401
  end

  # clean the pet

  it 'should return clean updated' do
    post "/pet/#{$apiKey}/clean/", {:email=>"riza@zinkus.com"}
    last_response.status.should == 202
  end

  it 'should return clean unauthorized (incorrect email)' do
    post "/pet/#{$apiKey}/clean/", {:email=>"thisIs@Incorrect.com"}
    last_response.status.should == 401
  end


  # now... check and see if values have been updated correctly.

  it 'should return clean = 100' do
    get "/pet/#{$apiKey}/cleanliness/"
    last_response.status.should == 200
    last_response.body.should == "100"
  end

  it 'should return hunger = 100' do
    get "/pet/#{$apiKey}/hunger/"
    last_response.status.should == 200
    last_response.body.should == "100"
  end

  it 'should return alive = true' do
    get "/pet/#{$apiKey}/alive/"
    last_response.status.should == 200
    last_response.body.should == "true"
  end

  # now... play with the pet. Playing adjusts cleanliness, hunger and mood.

  it 'should return play updated' do
    post "/pet/#{$apiKey}/play/", {:email=>"riza@zinkus.com"}
    last_response.status.should == 202
  end

  it 'should return play unauthorized (incorrect email)' do
    post "/pet/#{$apiKey}/clean/", {:email=>"thisIs@Incorrect.com"}
    last_response.status.should == 401
  end

  # now... check values of hunger and cleanliness

  it 'should return clean = 85' do
    get "/pet/#{$apiKey}/cleanliness/"
    last_response.status.should == 200
    last_response.body.should == "85"
  end

  it 'should return hunger = 85' do
    get "/pet/#{$apiKey}/hunger/"
    last_response.status.should == 200
    last_response.body.should == "85"
  end

  # now... feed pet again. feeding makes pet dirtier by 10.

  it 'should return feed updated' do
    post "/pet/#{$apiKey}/feed/", {:email=>"riza@zinkus.com"}
    last_response.status.should == 202
  end

  # check values... pet should be dirtier... but not hungry.

  it 'should return cleanliness = 7533' do
    get "/pet/#{$apiKey}/cleanliness/"
    last_response.status.should == 200
    last_response.body.should == "75"
  end

  it 'should return hunger = 100' do
    get "/pet/#{$apiKey}/hunger/"
    last_response.status.should == 200
    last_response.body.should == "100"
  end


end
