require 'kramdown'

module Helpers
  extend self
  def build_message(match)
    msg = <<-EOS 
#{match.winner.to_s.capitalize} won.
Players:

#{match.players.map do |p|
  "- #{p.team.to_s.capitalize} #{p}"
end.join("\n") + "\n"}

#{dotabuff_link(match)}
    EOS
    Kramdown::Document.new(msg).to_html
  end

  def dotabuff_link(match)
    "https://dotabuff.com/matches/#{match.id}"
  end
end