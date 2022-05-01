# Panopticon

A user-focused message logger for Discord, a la the built-in logging present in many IRC clients.

## Dependencies

* Python 3.6 or greater
* [discord.py](https://github.com/Rapptz/discord.py) 1.5.0 or later

## Installation, setup, and usage

* Clone the repo
* Copy config.py.example to config.py and edit it
* ./run.py

## Docker

A Docker image is provided as [ianburgwin/panopticon](https://hub.docker.com/repository/docker/ianburgwin/panopticon). A sample compose file is also provided in this repository.

Either `PANOPTICON_TOKEN` or `PANOPTICON_TOKEN_FILE` environment variables is required.

Configurable environment variables:

| Name | Description | Default |
| --- | --- | --- |
| **`PANOPTICON_TOKEN`** | Discord bot token, used over `PANOPTICON_TOKEN_FILE` if provided | (required) |
| **`PANOPTICON_TOKEN_FILE`** | File containing the Discord bot token, usually used with Docker secrets | (required) |
| `PANOPTICON_USE_LOCALTIME` | Whether or not to use local time (true) or UTC (false) for timestamps | false |
| `PANOPTICON_MAX_MESSAGES` | Maximum number of messages to cache, affecting how far back edits can be logged | 7500 |
| `PANOPTICON_AWAY_STATUS` | Status to display on Discord (available: online, offline, idle, dnd, do\_not\_disturb, invisible | idle |
| `PANOPTICON_IGNORE_SERVERS` | Comma-separated list of server IDs to ignore | |

## License
Panopticon is available under the terms of the BSD 3-clause license, which is located in this repository in the LICENSE file.

## Credits and Thanks
* Original author: Megumi Sonoda
* Rapptz for [discord.py](https://github.com/Rapptz/discord.py)
