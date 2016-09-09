#!/usr/bin/env ruby

# Panopticon by Megumi Sonoda
# Copyright 2016 Megumi Sonoda
# This file is licensed under the BSD 3-clause License

# To edit configuration, please copy config.rb.example to config.rb and edit there
require_relative 'config'

# Require other gems
require 'base64'
require 'fileutils'
require 'discordrb'
require 'zaru'

### Helper functions
# Get the proper filename & path
def filename(details, is_pm)
  if is_pm
    "#{details[:channel_name]}-#{details[:channel_id]}"
  else
    "\##{details[:channel_name]}-#{details[:channel_id]}"
  end
end

def filepath(details, is_pm)
  if is_pm
    'PM'
  else
    "#{details[:server_name]}-#{details[:server_id]}/"
  end
end

# Get attachment URLs
def attachment_urls(attachments)
  attachments.map { |u| "#{u.filename}: #{u.url}" }
end

# Substitute <@id> for prettier mentions
def sub_mentions(details)
  details[:mentions].each do |x|
    details[:content] = details[:content].gsub("<@#{x.id}>", "@#{x.distinct}")
    details[:content] = details[:content].gsub("<@!#{x.id}>", "@#{x.distinct}")
  end
  details[:content]
end

# Get the timestamp in the format we want
def timestamp(time)
  time = time.getutc if USE_UTC
  time.strftime('[%H:%M]')
end

# Build our message string
def make_message(details, is_edit)
  attachment_urls = attachment_urls(details[:attachments])
  time_string = timestamp(details[:time])
  details[:content] = sub_mentions(details)

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
  filepath = filepath(details, is_pm)
  filename = filename(details, is_pm)
  msg      = make_message(details, is_edit)
  write_to_file(filepath, filename, msg)
end

# Construct the logger object
LOG_BOT = Discordrb::Bot.new(
  token: LOGIN_TOKEN,
  application_id: APP_ID,
  type: LOGIN_TYPE,
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
    mentions: event.message.mentions,
    attachments: event.message.attachments
  }
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
    time: Time.now,
    content: event.message.content,
    mentions: event.message.mentions,
    attachments: event.message.attachments
  }
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
