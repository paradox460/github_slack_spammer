import cligen, os, strutils
import github_slack_spammer/slack_sender, github_slack_spammer/github_grabber

const NimblePkgVersion* {.strdefine.} = ""

proc github_slack_spammer(owner: string, repo: string, labels: seq[string] = @[], projects: seq[int] = @[], threshold: int = 2, channel: string, github_token: string, slack_token: string) =

  var pullRequests = getPullRequests(owner = owner, repo = repo, labels = labels, token = github_token)

  if projects.len != 0:
    pullRequests = pullRequests.filterByProject(projectIds = projects)

  pullRequests.filterApproved(threshold).outputMessage().sendMessage(channel = channel, token = slack_token)


when isMainModule:
  include cligen/mergeCfgEnv
  clCfg.version = NimblePkgVersion
  dispatch(github_slack_spammer, cmdname = "github_slack_spammer", positional = "", usage = """
NAME
  github_slack_spammer - Utility for taking PRs that are open and need review and spamming them into a slack channel.

USAGE
  $command $args

${doc}Options(opt-arg sep :|=|spc):

$options
""",help = {
    "owner": "The owner of the github project. Either a username or an org name.",
    "repo": "The repo name.",
    "labels": "Labels to filter Pull Requests by.",
    "projects": "Github project IDs to filter by. Project ID can be found in project board URL.",
    "threshold": "Upper threshold to filter. Any PRs with more approvals than this are omitted.",
    "channel": "Slack channel to send messages to. Either a unique name or a id.",
    "github_token": "Github Personal Access token. Needs the `repo` scope.",
    "slack_token": "Slack App token. Needs to have the `chat:write:user` permission."
  })