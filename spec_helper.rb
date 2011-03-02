require File.join(File.dirname(__FILE__), 'main.rb')

require 'rubygems'
require 'sinatra'
require 'test/unit'
require 'rack/test'
require 'rspec'

set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

#Rspec.configure do |config|
#  config.before(:each) { DataMapper.auto_migrate! }
#end