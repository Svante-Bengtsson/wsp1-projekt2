require 'bundler'
Bundler.require
require_relative 'app'
require 'rack/protection'
require 'securerandom'
long_hex_string = SecureRandom.hex(64).to_s
use Rack::Session::Cookie, secret: long_hex_string
use Rack::Protection::AuthenticityToken
run App