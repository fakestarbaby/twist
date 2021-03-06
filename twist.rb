require 'rubygems'
require 'bundler'
require 'em-twitter'
require 'json'
require 'hipchat'
require 'idobata'

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

EM.run do
  twitter_client = EM::Twitter::Client.connect(options)
  hipchat_client = HipChat::Client.new(ENV['HIPCHAT_API_TOKEN'])
  Idobata.hook_url = ENV['IDOBATA_HOOK_URL']

  twitter_client.each do |result|
    result = JSON.parse(result)
    next if ignore_users.include?(result['user']['screen_name'])
    next if track_keywords.include?(result['user']['screen_name'])

    status_url = "https://twitter.com/#{result['user']['screen_name']}/status/#{result['id']}"
    hipchat_client[ENV['HIPCHAT_ROOM_NAME']].send(ENV['HIPCHAT_SENDER_NAME'], status_url, message_format: 'text')
    Idobata::Message.create(source: "<p><span><img src=#{result['user']['profile_image_url']} width='16' height='16' /></span> <a href=#{status_url}>@#{result['user']['screen_name']}</a></p><blockquote>#{result['text']}</blockquote>", format: :html)
  end
end
