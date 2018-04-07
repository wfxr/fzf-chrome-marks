#!/usr/bin/env ruby
# encoding: utf-8

require 'json'
FILE = ARGV.first
CJK  = /\p{Han}|\p{Katakana}|\p{Hiragana}|\p{Hangul}|[［］，。！：；（）、？《》【】　]/

def build parent, json
    if json['type'] == 'folder'
        name = [parent, json['name']].compact.join('/')
        json['children'].map { |child| build name, child }
    else
        name = "\e[38;5;244m\e[3m#{parent}/\e[0m" + json['name']
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
        if len == width
            return str[0, idx]
        elsif len > width
            return str[0, idx - 1]
        end
    end
    str
end

width = [`tput cols`.strip.to_i * 2 / 3, 80].min
json  = JSON.load File.read File.expand_path FILE
items = json['roots']
    .values_at(*%w(bookmark_bar synced other))
    .compact
    .map { |e| build nil, e }
    .flatten

items.select{ |item| item[:url].start_with? 'http' }.each_with_index do |item, idx|
    name = trim item[:name], width + 6 # Color code occupy some spaces
    name = just name, width
    puts ["#{'%4d' % (idx + 1)} #{name}", item[:url]]
        .join("\t\x1b[34m") + "\x1b[m"
end
