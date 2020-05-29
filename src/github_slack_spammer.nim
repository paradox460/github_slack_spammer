import cligen, os, strutils, zero_functional
import github_slack_spammer/slack_sender, github_slack_spammer/github_grabber, github_slack_spammer/terminal_sender

const NimblePkgVersion* {.strdefine.} = ""

proc github_slack_spammer(
  owner: string,
  repos: seq[string],
  labels: seq[string] = @[],
  projects: seq[int] = @[],
  threshold: int = 2,
  channel: string = "",
  github_token: string,
  slack_token: string = "",
  quiet: bool = false,
  heading: string = "Hey guys, these PRs need reviews:") =

  echo "Fetching pull requests..."

  var pullRequests = repos --> map(getPullRequests(owner = owner, repo = it,
      labels = labels, token = github_token)) --> flatten()

  if projects.len != 0:
    pullRequests = pullRequests.filterByProject(projectIds = projects)

  pullRequests = pullRequests.filterDrafts().filterApproved(threshold).sortPullRequests()

  if pullRequests.len == 0:
    echo "No PRs matching criteria! Exiting 👋"
    quit(0)

  if quiet or channel == "" or slack_token == "":
    terminal_sender.sendMessage(pullRequests)
  else:
    slack_sender.sendMessage(pullRequests = pullRequests, heading = heading, channel = channel, token = slack_token)


when isMainModule:
  include cligen/mergeCfgEnv
  clCfg.version = NimblePkgVersion
  dispatch(github_slack_spammer, cmdname = "github_slack_spammer",
    positional = "",
    usage = """
NAME
  github_slack_spammer - Utility for taking PRs that are open and need review and spamming them into a slack channel.

USAGE
  $command $args

${doc}Options(opt-arg sep :|=|spc):

$options
""", help = {
    "owner": "The owner of the github project. Either a username or an org name.",
    "repos": "The repos to search.",
    "labels": "Labels to filter Pull Requests by.",
    "projects": "Github project IDs to filter by. Project ID can be found in project board URL.",
    "threshold": "Upper threshold to filter. Any PRs with more approvals than this are omitted.",
    "channel": "Slack channel to send messages to. Either a unique name or a id.",
    "github_token": "Github Personal Access token. Needs the `repo` scope.",
    "slack_token": "Slack App token. Needs to have the `chat:write:user` permission.",
    "quiet": "Output locally instead of to a slack channel. Implied if `slack_token` or `channel` are empty",
    "heading": "Line to output at the top of the message in slack."
  })
