require 'yaml'
require_relative 'dota'
require_relative 'flowdock'

Settings = YAML.load_file('keys.yml')

FlowDock.token = Settings['FLOW_API_KEY']
Dota.key       = Settings['STEAM_API_KEY']

time = ENV['LAST_CHECK'] || Time.now - 3600

matches = []
Settings['PLAYER_IDS'].each do |player_id|
  matches += Dota.matches({ account_id: player_id, date_min: time.to_i}).select {|m| m.start_time >= time }
end
puts matches.to_s
matches.flatten.each do |match|
  players = match.players.select {|p| player_ids.include? p.account_id.to_s }
  msg = {
    source: "Shopify Dota 2 Digest",
    from_address: 'not@anemail.com',
    subject: "Shopifiers #{players.join(", ")} played a match",
    content: "#{match.winner.to_s.capitalize} won. Players: #{match.players.map {|p| [p.team, p].join " "}.join "\n"}"
  }
  FlowDock.push(msg)
end
