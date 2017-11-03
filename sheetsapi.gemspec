Gem::Specification.new do |s|
  s.name        = 'sheetsapi'
  s.version     = '0.0.5'
  s.date        = '2017-03-08'
  s.summary     = "A simple API for writing to Google Sheets"
  s.description = "A simple API for writing to Google Sheets"
  s.authors     = ["Phusion B.V."]
  s.email       = ["info@phusion.nl"]
  s.homepage    = 'https://github.com/phusion/sheetsapi'
  s.files       = ["LICENSE", "README.md", "lib/sheetsAPI.rb"]
  s.license     = 'MIT'

  s.add_dependency 'google-api-client', '0.10.3'
end
