require 'bundler'
require 'em-twitter'
require 'json'
require 'httparty'

Bundler.require

track_keywords = ENV['TWITTER_TRACK_KEYWORDS']
ignore_users = (ENV['TWITTER_TRACK_IGNORE_USERS'] || '').split(/\s/)

options = {
  path:   '/1/statuses/filter.json',
  params: { track: track_keywords },
  oauth:  {
    consumer_key:    ENV['TWITTER_CONSUMER_KEY'],
    consumer_secret: ENV['TWITTER_CONSUMER_SECRET'],
    token:           ENV['TWITTER_OAUTH_TOKEN'],
    token_secret:    ENV['TWITTER_OAUTH_SECRET']
  }
}

hubot_endpoint = ENV['HUBOT_ENDPOINT']
hubot_room = ENV['HUBOT_ROOM']

EM.run do
  twitter_client = EM::Twitter::Client.connect(options)

  twitter_client.each do |matched|
    result = JSON.parse(matched)
    next if ignore_users.include?(result['user']['screen_name'])
    next if track_keywords.include?(result['user']['screen_name'])

    message = build_message(result)

    HTTParty.post(hubot_endpoint, room: hubot_room, message: message)
  end
end

def build_message(payload)
  user_image = payload['user']['profile_image_url_https']
  user_screen_name = payload['user']['screen_name']
  status = payload['text']
  status_url = "https://twitter.com/#{payload['user']['screen_name']}/status/#{payload['id_str']}"
  [user_image, user_screen_name, status, status_url].join("\n")
end
