
module Helpers
  extend self
  def build_message(match)
    "#{match.winner.to_s.capitalize} won.\n" +
    "Players: \n" +
    match.players.map do |p|
      "- #{p.team.to_s.capitalize} #{p}"
    end.join("\n") + "\n" + 
    dotabuff_link(match)
  end

  def dotabuff_link(match)
    "https://dotabuff.com/matches/#{match.id}"
  end
end