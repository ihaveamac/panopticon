#!/usr/bin/env ruby

# Panopticon by Megumi Sonoda
# Copyright 2016 Megumi Sonoda
# This file is licensed under the MIT License

# To edit configuration, please copy config.rb.example to config.rb and edit there
require_relative 'config'

# Require other gems
require 'base64'
require 'fileutils'
require 'discordrb'
require 'zaru'

### Helper functions
# Get the proper filename & path
def get_filename(details, is_pm)
  if is_pm
    "#{details[:channel_name]}-#{details[:channel_id]}"
  else
    "\##{details[:channel_name]}-#{details[:channel_id]}"
  end
end

def get_filepath(details, is_pm)
  if is_pm
    'PM/'
  else
    "#{details[:server_name]}-#{details[:server_id]}/"
  end
end

# Get attachment URLs
def get_attachment_urls(details)
  attachment_urls = []
  details[:attachments].each { |u| attachment_urls.push("#{u.filename}: #{u.url}") }
end

# Build our message string
def make_message(details, is_edit)
  attachment_urls = get_attachment_urls(details)

  time_string = details[:time].strftime('[%H:%M]')

  msg  = "#{is_edit ? '(E:' : '('}#{details[:message_id]}) #{time_string} <#{details[:author_name]}> #{details[:content].empty? ? '(message held no content)' : details[:content]}"
  msg += "\nAttachments: #{attachment_urls.join(', ')}" unless attachment_urls.empty?
  msg
end

# Wrapper to create folder if necessary & write to file
def write_to_file(filepath, filename, msg)
  FileUtils.mkdir_p "#{LOG_DIR}#{filepath}"
  File.open("#{LOG_DIR}#{filepath}#{filename}.txt", 'a') { |f| f.puts msg }
end

# Log messages
def log_message(details, is_pm, is_edit)
  filepath = get_filepath(details, is_pm)
  filename = get_filename(details, is_pm)
  msg      = make_message(details, is_edit)
  write_to_file(filepath, filename, msg)
end

# Construct the logger object
LOG_BOT = Discordrb::Bot.new(
  token: LOGIN_TOKEN,
  type: :user,
  parse_self: true
)

# Message sent
LOG_BOT.message do |event|
  details = {
    channel_id: event.message.channel.id,
    message_id: Base64.strict_encode64([event.message.id].pack('L<')),
    channel_name: Zaru.sanitize!(event.message.channel.name),
    author_name: event.message.author.distinct,
    time: event.message.timestamp,
    content: event.message.content,
    attachments: event.message.attachments
  }
  details[:time] = details[:time].getutc if USE_UTC
  unless event.channel.private?
    details[:server_id]   = event.server.id
    details[:server_name] = Zaru.sanitize!(event.server.name)
  end

  log_message(details, event.channel.private?, false)
end

# Message edited
LOG_BOT.message_edit do |event|
  details = {
    channel_id: event.message.channel.id,
    message_id: Base64.strict_encode64([event.message.id].pack('L<')),
    channel_name: Zaru.sanitize!(event.message.channel.name),
    author_name: event.message.author.distinct,
    time: event.message.timestamp,
    content: event.message.content,
    attachments: event.message.attachments
  }
  details[:time] = details[:time].getutc if USE_UTC
  unless event.channel.private?
    details[:server_id]   = event.server.id
    details[:server_name] = Zaru.sanitize!(event.server.name)
  end

  log_message(details, event.channel.private?, true)
end

# Catch SIGINT/SITERM and shutdown
def shutdown_bot
  LOG_BOT.stop
  exit
end
trap('SIGINT') { shutdown_bot }
trap('SIGTERM') { shutdown_bot }

# Run the logger
LOG_BOT.run
