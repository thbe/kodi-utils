#! /bin/ruby
#
# This script generates a HTML page of movies and TV series
# based on the content from Kodi videodb.xml
#
# Author:  Thomas Bendler <project@bendler-net.de>
# Date:    Fri Jan 23 18:50:37 CET 2015
#
# Version: v0.9
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
  movie_array[movie_counter] = [title, country, director, studio, year, runtime, story, poster_url]
  movie_counter += 1
  # --- Debug ---
  # puts "Titel:      " + title
  # puts "Country:    " + country
  # puts "Director:   " + director
  # puts "Studio:     " + studio
  # puts "Year:       " + year
  # puts "Runtime:    " + runtime
  # puts "Story:      " + story
  # puts "Poster URL: " + poster_url
  # puts ""
end

# Initialize and populate tvshow array
puts "Generate tvshow array ..."
tvshow_array = Array.new(doc.xpath('//tvshow/episodedetails').count) { Array.new(7) }
tvshow_counter = 0
doc.xpath('//tvshow/episodedetails').each do |tvshow|
  if !tvshow.at_xpath('title').nil?
    title = tvshow.at_xpath('title').content
  end
  if !tvshow.at_xpath('showtitle').nil?
    showtitle = tvshow.at_xpath('showtitle').content
  end
  if !tvshow.at_xpath('season').nil?
    season = tvshow.at_xpath('season').content
  end
  if !tvshow.at_xpath('episode').nil?
    episode = tvshow.at_xpath('episode').content
  end
  if !tvshow.at_xpath('year').nil?
    year = tvshow.at_xpath('year').content
  end
  if !tvshow.at_xpath('runtime').nil?
    runtime = tvshow.at_xpath('runtime').content + " minutes"
  end
  if !tvshow.at_xpath('plot').nil?
    story = tvshow.at_xpath('plot').content
  end
  if !tvshow.at_xpath('thumb').nil?
    poster_url = tvshow.at_xpath('thumb').content
  end
  if title.to_s.strip.length == 0
    title = "No information available"
  end
  if showtitle.to_s.strip.length == 0
    showtitle = "No information available"
  end
  if season.to_s.strip.length == 0
    season = "No information available"
  end
  if episode.to_s.strip.length == 0
    episode = "No information available"
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
  tvshow_array[tvshow_counter] = [title, showtitle, season, episode, year, runtime, story, poster_url]
  tvshow_counter += 1
  # --- Debug ---
  # puts "TV-Show:    " + showtitle
  # puts "Title:      " + title
  # puts "Season:     " + season
  # puts "Episode:    " + episode
  # puts "Year:       " + year
  # puts "Runtime:    " + runtime
  # puts "Story:      " + story
  # puts "Poster URL: " + poster_url
  # puts ""
end

# Generate picture cache (skip if image already exists)
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
one_pixel_gif_content = open("http://upload.wikimedia.org/wikipedia/commons/c/c0/Blank.gif").read
File.open(outputlocation + "/cache/blank.gif", 'w'){|file| file.write(one_pixel_gif_content)}
movie_counter = 0
movie_array.each do |row|
  url = row[7]
  movie_array[movie_counter][7] = "cache/blank.gif"
  download_status = " - failed\n"
  print movie_array[movie_counter][0]
  print " - "
  print url
  if url != "No information available"
    url_parsed = URI.parse(url)
    movie_picture_host = url_parsed.host
    movie_picture_name = File.basename(url_parsed.path)
    movie_picture_filename = "cache/" + movie_picture_name
  end
  if movie_picture_host.to_s.strip.length != 0
    if ! File.exists?(movie_picture_filename)
      if host_name_exist(movie_picture_host)
        return_code = Net::HTTP.get_response(URI.parse(url.to_s)).code
        if return_code == "200" or return_code == "301" or return_code == "302"
          movie_picture_content = open(url).read
          File.open(movie_picture_filename, 'w'){|file| file.write(movie_picture_content)}
          movie_array[movie_counter][7] = movie_picture_filename
          download_status = " - done\n"
        end
      end
    else
      movie_array[movie_counter][7] = movie_picture_filename
      download_status = " - skipped, image already in cache\n"
    end
  end
  print download_status
  movie_counter += 1
end
tvshow_counter = 0
tvshow_array.each do |row|
  url = row[7]
  tvshow_array[tvshow_counter][7] = "cache/blank.gif"
  download_status = " - failed\n"
  print tvshow_array[tvshow_counter][0]
  print " - "
  print url
  if url != "No information available"
    url_parsed = URI.parse(url)
    tvshow_picture_host = url_parsed.host
    tvshow_picture_name = File.basename(url_parsed.path)
    tvshow_picture_filename = "cache/" + tvshow_picture_name
  end
  if tvshow_picture_host.to_s.strip.length != 0
    if ! File.exists?(tvshow_picture_filename)
      if host_name_exist(tvshow_picture_host)
        return_code = Net::HTTP.get_response(URI.parse(url.to_s)).code
        if return_code == "200" or return_code == "301" or return_code == "302"
          tvshow_picture_content = open(url).read
          File.open(tvshow_picture_filename, 'w'){|file| file.write(tvshow_picture_content)}
          tvshow_array[tvshow_counter][7] = tvshow_picture_filename
          download_status = " - done\n"
        end
      end
    else
      tvshow_array[tvshow_counter][7] = tvshow_picture_filename
      download_status = " - skipped, image already in cache\n"
    end
  end
  print download_status
  tvshow_counter += 1
end

# Generate HTML file out of movie grid
puts "Generate HTML output ..."
video_html_file = File.new(outputfile, "w+")
video_html_file.puts "<html>"
video_html_file.puts "<head>"
video_html_file.puts "  <title>Kodi Mediacenter Content List</title>"
video_html_file.puts "  <meta charset=\"UTF-8\">"
video_html_file.puts "  <style type=\"text/css\">"
video_html_file.puts "    #kodi {"
video_html_file.puts "      font-family: \"HelveticaNeue-Light\","
video_html_file.puts "                   \"Helvetica Neue Light\","
video_html_file.puts "                   \"Helvetica Neue\","
video_html_file.puts "                    Helvetica, Arial,"
video_html_file.puts "                   \"Lucida Grande\", sans-serif;"
video_html_file.puts "      font-weight: 300;"
video_html_file.puts "      width: 100%;"
video_html_file.puts "      border-collapse: collapse;"
video_html_file.puts "    }"
video_html_file.puts "    #kodi td, #kodi th {"
video_html_file.puts "      font-size: 1em;"
video_html_file.puts "      border: 1px solid #98bf21;"
video_html_file.puts "      padding: 3px 7px 2px 7px;"
video_html_file.puts "      align: justify;"
video_html_file.puts "      valign: top;"
video_html_file.puts "    }"
video_html_file.puts "    #kodi th {"
video_html_file.puts "      font-size: 1.1em;"
video_html_file.puts "      text-align: left;"
video_html_file.puts "      padding-top: 5px;"
video_html_file.puts "      padding-bottom: 4px;"
video_html_file.puts "      background-color: #A7C942;"
video_html_file.puts "      color: #ffffff;"
video_html_file.puts "    }"
video_html_file.puts "    #kodi tr.alt td {"
video_html_file.puts "      color: #000000;"
video_html_file.puts "      background-color: #EAF2D3;"
video_html_file.puts "    }"
video_html_file.puts "    #kodi img {"
video_html_file.puts "      max-width: 128px;"
video_html_file.puts "      max-height: 128px;"
video_html_file.puts "      width: auto;"
video_html_file.puts "      height: auto;"
video_html_file.puts "    }"
video_html_file.puts "    #kodi h1 {"
video_html_file.puts "      align: center;"
video_html_file.puts "    }"
video_html_file.puts "  </style>"
video_html_file.puts "</head>"
video_html_file.puts "<body>"
video_html_file.puts "  <h1 id=\"kodi\">Kodi Mediacenter Movie Content List</h1>"
video_html_file.puts "  <table id=\"kodi\">"
video_html_file.puts "    <tr>"
video_html_file.puts "      <th width=\"10%\">Poster</th>"
video_html_file.puts "      <th width=\"25%\">Information</th>"
video_html_file.puts "      <th>Story</th>"
video_html_file.puts "    </tr>"
table_row_format = "    <tr>"
movie_array.each do |row|
  video_html_file.puts table_row_format
  video_html_file.puts "      <td><img src=\"#{row[7]}\"></td>"
  video_html_file.puts "      <td>"
  video_html_file.puts "        <b>Title: #{row[0]}</b><br />"
  video_html_file.puts "        Country: #{row[1]}<br />"
  video_html_file.puts "        Director: #{row[2]}<br />"
  video_html_file.puts "        Studio: #{row[3]}<br />"
  video_html_file.puts "        Year: #{row[4]}<br />"
  video_html_file.puts "        Runtime: #{row[5]}<br />"
  video_html_file.puts "      </td>"
  video_html_file.puts "      <td>#{row[6]}</td>"
  video_html_file.puts "    </tr>"
  if table_row_format == "    <tr>"
    table_row_format = "    <tr class=\"alt\">"
  else
    table_row_format = "    <tr>"
  end
end
video_html_file.puts "  </table>"
video_html_file.puts "  <h1 id=\"kodi\">Kodi Mediacenter TV Series Content List</h1>"
video_html_file.puts "  <table id=\"kodi\">"
video_html_file.puts "    <tr>"
video_html_file.puts "      <th width=\"10%\">Poster</th>"
video_html_file.puts "      <th width=\"25%\">Information</th>"
video_html_file.puts "      <th>Story</th>"
video_html_file.puts "    </tr>"
table_row_format = "    <tr>"
tvshow_array.each do |row|
  video_html_file.puts table_row_format
  video_html_file.puts "      <td><img src=\"#{row[7]}\"></td>"
  video_html_file.puts "      <td>"
  video_html_file.puts "        <b>TV-Show: #{row[1]}</b><br />"
  video_html_file.puts "        Title: #{row[0]}<br />"
  video_html_file.puts "        Season: #{row[2]}<br />"
  video_html_file.puts "        Episode: #{row[3]}<br />"
  video_html_file.puts "        Year: #{row[4]}<br />"
  video_html_file.puts "        Runtime: #{row[5]}<br />"
  video_html_file.puts "      </td>"
  video_html_file.puts "      <td>#{row[6]}</td>"
  video_html_file.puts "    </tr>"
  if table_row_format == "    <tr>"
    table_row_format = "    <tr class=\"alt\">"
  else
    table_row_format = "    <tr>"
  end
end
video_html_file.puts "  </table>"
video_html_file.puts "</body>"
video_html_file.puts "</html>"
video_html_file.close()

puts ""
puts "HTML files successfully generated!"
