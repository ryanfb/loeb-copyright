#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'yaml'
require 'net/https'
require 'uri'
require 'open-uri'
require 'csv'

def get_redirect(uri)
  url = URI.parse(uri)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  res = http.start {|http|
    http.head(url.path)
  }
  res['location']
end

def is_200?(uri)
  url = URI.parse(uri)
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.head(url.path)
  }
  $stderr.puts "#{res.code} for #{uri}"
  res.code == '200'
end

doc = Nokogiri::HTML(open('http://www.edonnelly.com/loebs.html'))

associations = {}

doc.xpath('//a[contains(@href,"books.google.com") or contains(@href,"www.archive.org") or (@href = ".")]').each do |link|
  loeb = link.xpath('preceding::a[contains(@href,"hup.harvard.edu")][2]').first
  title = loeb.xpath('following::td[1]').first.content
  original_title = loeb.xpath('following::td[1]/following::i[1]').first.content
  /Original (?<original_year>\d+) Title/ =~ loeb.xpath('following::td[1]/following::i[1]/parent::td[1]').first.content

  # $stderr.puts [loeb, title, original_title, link['href']].join(',')

  author = title.split(' -- ').first
  title = title.split(' -- ').last
  if author =~ /,/ # only modern authors have a comma in the name
    author = ''
  end

  loeb = loeb.content

  unless associations.has_key? loeb
    associations[loeb] = {}
    associations[loeb]['author'] = author
    associations[loeb]['original_title'] = original_title
    associations[loeb]['original_year'] = original_year
    if title != original_title
      if original_title.nil? || original_title.empty?
        associations[loeb]['original_title'] = title
      else
        associations[loeb]['new_title'] = title
      end
    end
    if is_200?("http://ryanfb.github.io/loebolus-data/#{loeb}.pdf")
      associations[loeb]['in_loebolus'] = true
    else
      associations[loeb]['in_loebolus'] = false
    end
  end

  if link['href'] =~ /www.archive.org/
    associations[loeb]['archive'] = link['href']

    id = link['href'].split('/').last
    # associations[loeb]['openlibrary'] = get_redirect("https://openlibrary.org/ia/#{id}")
  elsif link['href'] != "."
    associations[loeb]['google'] = link['href']
  end
end

# puts associations.to_yaml
CSV.open('loeb-copyright-old.csv', "wb") do |csv|
  csv << %w{identifier author title year_published pre_1923 1923-1963_copyright_not_renewed in_loebolus notes urls}
  associations.each_key do |volume|
    urls = [associations[volume]['archive'], associations[volume]['google']].join(' ').strip
    notes = ''
    if associations[volume]['new_title']
      notes = "New title: #{associations[volume]['new_title']}"
    end
    pre_1923 = associations[volume]['original_year'] && (associations[volume]['original_year'].to_i < 1923)
    not_renewed = (associations[volume]['original_year'] && 
      (associations[volume]['original_year'].to_i >= 1923) &&
      (associations[volume]['original_year'].to_i <= 1963) &&
      associations[volume]['in_loebolus']) || ''
    if associations[volume]['in_loebolus'] && associations[volume]['original_year'] && (associations[volume]['original_year'].to_i > 1963)
      $stderr.puts "COPYRIGHT WARNING: #{volume}"
    end
    if associations[volume]['in_loebolus'] && !associations[volume]['original_year']
      $stderr.puts "NEEDS_YEAR: #{volume}"
    end
    if pre_1923 && !associations[volume]['in_loebolus']
      $stderr.puts "NEEDS_PDF: #{volume}"
    end
    csv << [volume, associations[volume]['author'], associations[volume]['original_title'], associations[volume]['original_year'], pre_1923, not_renewed, associations[volume]['in_loebolus'], notes, urls]
  end
end
