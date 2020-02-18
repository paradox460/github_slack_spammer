# Github Slack Spammer

A utility for taking open PRs that need approvals, and spamming them into a slack channel.

# Installation

If you have nim installed, you can do this via nimble

```sh
nimble install https://github.com/paradox460/github_slack_spammer
```

If you don't have nim installed, you can use homebrew.

```sh
brew install paradox460/formulae/github_slack_spammer
```

# Usage
You can run `--help` at any time for the most up-to-date version

```
github_slack_spammer [options]
```

## Options
| Short | Long           | Type     | Default  | Description                                                                             |
| ----- | -------------- | -------- | -------- | --------------------------------------------------------------------------------------- |
| h     | --help         |          |          | Shows online help                                                                       |
|       | --help-syntax  |          |          | Shows advanced command line syntax help                                                 |
| o     | --owner        | string   | REQUIRED | GitHub project owner                                                                    |
| r     | --repo         | string   | REQUIRED | GitHub repository                                                                       |
| l     | --labels       | [string] |          | Labels to filter pull requests by                                                       |
| p     | --projects     | [int]    |          | Github project board IDs to filter PRs by                                               |
| t     | --threshold    | int      | 2        | Upper threshold of approvals to filter out.                                             |
| c     | --channel      | string   | REQUIRED | Slack channel to spam into. Can be a channel name or ID                                 |
| g     | --github_token | string   | REQUIRED | Github Personal Access Token. Needs the `repo` scope                                    |
| s     | --slack_token  | string   |          | Slack app token. Needs the `chat:write:user` permission, and to be authed to your user. |
| q     | --quiet        |          |          | Outputs locally instead of to a slack channel. Implied if `slack_token` is absent       |

# Config
You can set command defaults in two ways, so you don't have to set them every time.

## Envars
Set an envar named `GITHUB_SLACK_SPAMMER` with whatever CLI params you wish to set.

```sh
env GITHUB_SLACK_SPAMMER="-o paradox460 -r github_slack_spammer -c #ghss -g mytoken -s mytoken" github_slack_spammer
```

This is useful if you use things like [direnv](https://direnv.net/)

## Config files
You can also set a global config file at `~/.config/github_slack_spammer` Put, on their own lines, each cli param you wish to use. Format of config file is [Nim's parsecfg format](https://nim-lang.org/docs/parsecfg.html), which resembles INI

```ini
--owner = "paradox460"
--repo = "github_slack_spammer"
--channel = "#ghss"
--github_token = "token"
--slack_token = "token"
```

You can combine config files, envars, and cli invocations. Config values cascade, with CLI being the highest-priority. See `--help-syntax` for info

# License
MIT License

Copyright (c) 2020 Jeff Sandberg

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
