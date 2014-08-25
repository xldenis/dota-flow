require 'httparty'

module FlowDock
  extend self

  attr_accessor :token

  def push(msg)
    HTTParty.post "https://api.flowdock.com/v1/messages/team_inbox/#{token}",
    body: msg.to_json,
    headers: {'Content-Type' => 'application/json'}
  end
end
