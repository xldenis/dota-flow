require 'yaml'

Dir[File.dirname(__FILE__) + '/*.rb'].each {|file| require file }

KEYS = Settings.new('keys.yml')

FlowDock.token = KEYS['FLOW_API_KEY']
Dota.key       = KEYS['STEAM_API_KEY']

time = ENV['LAST_CHECK'] || Time.now - 3600 * 36

namespace :dota do
  desc "Push recent dota matches to flowdock"
  task :push do
    matches = []
    KEYS['PLAYER_IDS'].each do |player_id|
      matches += Dota.matches({ account_id: player_id, date_min: time.to_i}).select {|m| m.start_time >= time }
    end
    matches.flatten.each do |match|
      players = match.players.select {|p| KEYS['PLAYER_IDS'].include? p.account_id.to_s }
      msg = {
        source: "Shopify Dota 2 Digest",
        from_address: 'not@anemail.com',
        subject: "Shopifiers #{players.join(", ")} played a match",
        content: Helpers::build_message(match)
      }
      puts msg
      FlowDock.push(msg)
    end

  end
end


