require 'bundler'
Bundler.require
require_relative 'app'
require 'rack/protection'
use Rack::Protection::AuthenticityToken
run App