# Panopticon

A user-focused message logger for Discord, a la the built-in logging present in many IRC clients.

## Dependencies

* Ruby 2.1 or greater
* [discordrb](https://github.com/meew0/discordrb)
* [Zaru](https://github.com/madrobby/zaru)

## Installation, setup, and usage

* Clone the repo
* Copy config.rb.example to config.rb and edit it
* ./run.rb

### Notes

You may periodically see a message in your terminal along the lines of:

`The bot does not have permission to do this!`

followed by a string of errors.

This relates to discordrb, the library Panopticon utilizes, and the way User objects are managed.

## License
Panopticon is available under the terms of the BSD 3-clause license, which is located in this repository in the LICENSE file.

## Credits and Thanks
* Megumi Sonoda ([GitHub](https://github.com/megumisonoda), [Twitter](https://twitter.com/dreamyspell))


* meew0 for [discordrb](https://github.com/meew0/discordrb)
* madrobby for [Zaru](https://github.com/madrobby/zaru)
