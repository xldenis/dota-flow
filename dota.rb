require 'httparty'

module Dota
  extend self

  attr_accessor :key

  @@players = {}

  def heroes
    @@heroes ||= begin
      (HTTParty.get "https://api.steampowered.com/IEconDOTA2_570/GetHeroes/v0001/",
        query: {key: key, language: 'en_us'})
      .parsed_response['result']['heroes']
      .map {|h| {h['id'].to_i => h['localized_name']}}.reduce(&:merge)

    end
  end

  def matches(query)
    resp = HTTParty.get "https://api.steampowered.com/IDOTA2Match_570/GetMatchHistory/V001/",
      query: query.merge({key: key})
    if resp.code == 200
      (resp.parsed_response['result']['matches'].map {|m| Match.new(m)})
    end
  end

  def player(id)
    pid = id + 76561197960265728 # convert to 64-bit steam ids
    @@players[pid] ||= begin
      resp = HTTParty.get "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/",
        query: {steamids: pid, key: Dota.key}
      if resp.code == 200
        players = resp.parsed_response['response']['players']
        id = players[0]['personaname'] unless players.empty?
        id != 4294967295 ? id : 'Private Name' # 4294967295 is the private acc number
      end
    end
  end

  class Match
    attr_reader :start_time, :players, :id, :lobby_type

    LOBBY_TYPES = { -1 => :invalid, 0 => :public_matchmaking, 1 => :practice, 2 => :tournament, 3 => :tutorial, 4 => :co_op_bots, 5 => :team_match, 6 => :solo}

    def initialize(match)
      @start_time = Time.at(match['start_time'])
      @players    = match['players'].map {|p| Player.new(p)}
      @id   = match['match_id']
      @lobby_type = match['lobby_type']
    end

    def details
      @details ||= begin
        resp = HTTParty.get "https://api.steampowered.com/IDOTA2Match_570/GetMatchDetails/v1",
          query: {key: Dota.key, match_id: @match_id}
        if resp.code == 200
          resp.parsed_response['result']
        end
      end
    end

    private :details

    def lobby
      LOBBY_TYPES[@lobby_type]
    end

    def winner
      details['radiant_win'] ? :radiant : :dire
    end 

    class Player
      attr_reader :account_id, :hero_id, :player_slot

      def initialize(player)
        @account_id  = player['account_id']
        @hero_id     = player['hero_id']
        @player_slot = player['player_slot']
      end

      def team
        (@player_slot & 0x80) != 0 ? :dire : :radiant
      end

      def position
        (@player_slot & 0x7).to_i
      end

      def hero
        Dota.heroes[@hero_id]
      end

      def name
        Dota.player(account_id) || account_id
      end

      def to_s
        "#{name} - #{hero}"
      end
    end
  end
end
