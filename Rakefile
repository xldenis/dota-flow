require 'yaml'
require_relative 'dota'
require_relative 'flowdock'

Settings = YAML.load_file('keys.yml')

FlowDock.token = Settings['FLOW_API_KEY']
Dota.key       = Settings['STEAM_API_KEY']

time = ENV['LAST_CHECK'] || Time.now - 3600*36

namespace :dota do
  desc "Push recent dota matches to flowdock"
  task :push do
    matches = []
    Settings['PLAYER_IDS'].each do |player_id|
      matches += Dota.matches({ account_id: player_id, date_min: time.to_i}).select {|m| m.start_time >= time }
    end
    matches.flatten.each do |match|
      players = match.players.select {|p| Settings['PLAYER_IDS'].include? p.account_id.to_s }
      msg = {
        source: "Shopify Dota 2 Digest",
        from_address: 'not@anemail.com',
        subject: "Shopifiers #{players.join(", ")} played a match",
        content: build_message(match)
      }
      puts msg
      # FlowDock.push(msg)
    end

  end
end

def build_message(match)
  "#{match.winner.to_s.capitalize} won.\n" +
  "Players: \n" +
  match.players.map do |p|
    "- #{p.team.to_s.capitalize} #{p}"
  end.join("\n") + 
  dotabuff_link(match)
end

def dotabuff_link(match)
  "https://dotabuff.com/matches/#{match.id}"
end
