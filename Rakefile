require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

desc "Deploy website to s3"
task :deploy do
  puts "Building website"
  sh "jekyll build"

  puts "Deploying website"
  sh "s3_website push"

  puts "Website deployed"
end
