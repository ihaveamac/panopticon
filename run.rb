#!/usr/bin/env ruby

# Discord PM Logger by Megumi Sonoda
# Copyright 2016 Megumi Sonoda
# This file is licensed under the MIT License

# Configuration
# Get login token by ctrl+shift+i, console, localStorage.token
LOGIN_TOKEN = ''.freeze
LOG_DIR = 'logs/'.freeze
USE_UTC = true

# Require other gems
require 'base64'
require 'fileutils'
require 'discordrb'

# If our specified folder doesn't exist, create it
FileUtils.mkdir_p LOG_DIR unless File.exist?(LOG_DIR)

# Small function to handle writing to file
def write_to_file(file, data)
  File.open("#{LOG_DIR}#{file}.txt", 'a') { |f| f.puts data }
end

# Constructor
LOG_BOT = Discordrb::Bot.new(
  token: LOGIN_TOKEN,
  type: :user,
  parse_self: true
)

# Catch SIGINT/SITERM and shutdown
def shutdown_bot
  LOG_BOT.stop
  exit
end
trap('SIGINT') { shutdown_bot }
trap('SIGTERM') { shutdown_bot }

# Event handler for messages
LOG_BOT.message do |event|
  if event.channel.private?
    details = {
      channel_id: event.message.channel.id,
      message_id: event.message.id,
      author_name: event.message.author.distinct,
      time: event.message.timestamp,
      content: event.message.content,
      attachments: event.message.attachments
    }
    attachment_urls = []
    details[:attachments].each { |u| attachment_urls.push("#{u.filename}: #{u.url}") }
    details[:time] = details[:time].getutc if USE_UTC
    time_string = details[:time].strftime('[%H:%M]')
    msg_id = Base64.strict_encode64([details[:message_id]].pack('L<'))
    msg = "(#{msg_id}) #{time_string} <#{details[:author_name]}> #{details[:content].empty? ? '(message held no content)' : details[:content]}"
    msg += "\nAttachments: #{attachment_urls.join(', ')}" unless attachment_urls.empty?
    msg += "\n" if details[:content].include?("\n")
    write_to_file(details[:channel_id].to_s, msg)
  end
end

LOG_BOT.message_edit do |event|
  if event.channel.private?
    details = {
      channel_id: event.message.channel.id,
      message_id: event.message.id,
      author_name: event.message.author.distinct,
      time: event.message.timestamp,
      content: event.message.content
    }
    details[:time] = details[:time].getutc if USE_UTC
    time_string = details[:time].strftime('[%H:%M]')
    msg_id = Base64.strict_encode64([details[:message_id]].pack('L<'))
    msg = "(E: #{msg_id}) #{time_string} <#{details[:author_name]}> #{details[:content].empty? ? '(message held no content)' : details[:content]}"
    msg += "\n" if details[:content].include?("\n")
    write_to_file(details[:channel_id].to_s, msg)
  end
end

LOG_BOT.run
