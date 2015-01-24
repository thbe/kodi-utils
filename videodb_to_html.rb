#! /bin/ruby
#
# This script generates a HTML page of movies and TV series
# based on the content from Kodi videodb.xml
#
# Author: Thomas Bendler <project@bendler-net.de>
# Date:   Fri Jan 23 18:50:37 CET 2015
#


# Include required libraries
require 'nokogiri'
require 'open-uri'
require 'uri'
require 'net/http'

# Let user specify path of input and output file
print "Please specify location for input and output file\n"
print "Press <return> if current path should be used\n"
print "Location of input file videodb.xml: "
inputlocation = gets.chomp
print "Location of output file kodi-content.html: "
outputlocation = gets.chomp

# Construct files plus locations and populate content array
if inputlocation.empty?
  inputlocation = Dir.pwd
end
inputfile = inputlocation + "/videodb.xml"
inputfile_content = File.new(inputfile, 'r')
if outputlocation.empty?
  outputlocation = Dir.pwd
end
outputfile = outputlocation + "/kodi-content.html"

# Use nokogiri framework to parse input file content
doc = Nokogiri::XML(inputfile_content)

# Initialize and populate movie array
puts "Generate movie array ..."
movie_array = Array.new(doc.xpath('//movie').count) { Array.new(7) }
movie_counter = 0
doc.xpath('//movie').each do |movie|
  if !movie.at_xpath('title').nil?
    title = movie.at_xpath('title').content
  end
  if !movie.at_xpath('country').nil?
    country = movie.at_xpath('country').content
  end
  if !movie.at_xpath('director').nil?
    director = movie.at_xpath('director').content
  end
  if !movie.at_xpath('studio').nil?
    studio = movie.at_xpath('studio').content
  end
  if !movie.at_xpath('year').nil?
    year = movie.at_xpath('year').content
  end
  if !movie.at_xpath('runtime').nil?
    runtime = movie.at_xpath('runtime').content + " minutes"
  end
  if !movie.at_xpath('outline').nil?
    story = movie.at_xpath('outline').content
  end
  if !movie.at_xpath('thumb').nil?
    poster_url = movie.at_xpath('thumb').content
  end
  if title.to_s.strip.length == 0
    title = "No information available"
  end
  if country.to_s.strip.length == 0
    country = "No information available"
  end
  if director.to_s.strip.length == 0
    director = "No information available"
  end
  if studio.to_s.strip.length == 0
    studio = "No information available"
  end
  if year.to_s.strip.length == 0
    year = "No information available"
  end
  if runtime.to_s.strip.length == 0
    runtime = "No information available"
  end
  if story.to_s.strip.length == 0
    story = "No information available"
  end
  if poster_url.to_s.strip.length == 0
    poster_url = "No information available"
  end
  movie_array[movie_counter][0] = title
  movie_array[movie_counter][1] = country
  movie_array[movie_counter][2] = director
  movie_array[movie_counter][3] = studio
  movie_array[movie_counter][4] = year
  movie_array[movie_counter][5] = runtime
  movie_array[movie_counter][6] = story
  movie_array[movie_counter][7] = poster_url
  movie_counter += 1
end

# Generate picture cache
puts "Generate picture cache ..."
def host_name_exist (host_name)
  require "resolv"
  dns_resolver = Resolv::DNS.new()
  begin
    dns_resolver.getaddress(host_name)
    return true
  rescue Resolv::ResolvError => e
    return false
  end
end
Dir.mkdir(outputlocation + "/cache") unless Dir.exists?(outputlocation + "/cache")
movie_array.each do |row|
  url = row[7]
  puts url
  next if url == "No information available"
  url_parsed = URI.parse(url)
  movie_picture_host = url_parsed.host
  movie_picture_name = File.basename(url_parsed.path)
  if movie_picture_host.to_s.strip.length != 0
    if host_name_exist(movie_picture_host)
      return_code = Net::HTTP.get_response(URI.parse(url.to_s)).code
      puts return_code
      if return_code == "200" or return_code == "301" or return_code == "302"
        puts movie_picture_name
        movie_picture_content = open(url).read
        movie_picture_filename = "cache/" + movie_picture_name
        File.open(movie_picture_filename, 'w'){|file| file.write(movie_picture_content)}
      end
    end
  end
end

# Generate HTML file out of movie grid
puts "Generate HTML output ..."
video_html_file = File.new(outputfile, "w+")
video_html_file.puts "<html>"
video_html_file.puts "<title>Kodi Mediacenter Content List</title>"
video_html_file.puts "<body>"
video_html_file.puts "<div id=\"main\">"
video_html_file.puts "<h1>Kodi Mediacenter Content List</h1>"
video_html_file.puts "<table border=\"1\">"
movie_array.each do |row|
  url_parsed = URI.parse(row[7])
  movie_picture_name = File.basename(url_parsed.path)
  movie_picture_filename = "cache/" + movie_picture_name
  video_html_file.puts "<tr>"
  video_html_file.puts "<td><img src=\"#{movie_picture_filename}\" height=\"128\" width=\"128\"></td>"
  video_html_file.puts "<td>#{row[0]}<br />#{row[1]}<br />#{row[2]}<br />#{row[3]}<br />#{row[4]}<br />#{row[5]}</td>"
  video_html_file.puts "<td>#{row[6]}</td>"
  video_html_file.puts "</tr>"
end
video_html_file.puts "</div>"
video_html_file.puts "<div id=\"side\">"
video_html_file.puts "</div>"
video_html_file.puts "</body>"
video_html_file.puts "</html>"
video_html_file.close()

puts ""
puts "HTML files successfully generated!"
# Debug
# puts movie_array

# TODO tv series need to be catched as well
