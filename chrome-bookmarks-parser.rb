#!/usr/bin/env ruby
# encoding: utf-8

require 'json'
FILE = ARGV.first
CJK  = /\p{Han}|\p{Katakana}|\p{Hiragana}|\p{Hangul}/

def build parent, json
    name = [parent, json['name']].compact.join('/')
    if json['type'] == 'folder'
        json['children'].map { |child| build name, child }
    else
        { name: name, url: json['url'] }
    end
end

def just str, width
    str.ljust(width - str.scan(CJK).length)
end

def trim str, width
    # Remove 'Bookmarks Bar' prefix which is the default bookmarks root
    str = str.gsub 'Bookmarks bar/', ''
    len = 0
    str.each_char.each_with_index do |char, idx|
        len += char =~ CJK ? 2 : 1
        return str[0, idx] if len > width
    end
    str
end

width = `tput cols`.strip.to_i / 2
json  = JSON.load File.read File.expand_path FILE
items = json['roots']
    .values_at(*%w(bookmark_bar synced other))
    .compact
    .map { |e| build nil, e }
    .flatten

items.each do |item|
    name = trim item[:name], width
    puts [just(name, width),
          item[:url]].join("\t\x1b[36m") + "\x1b[m"
end
