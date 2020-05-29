import httpclient, json, sequtils, strformat, strutils
from ./github_grabber import PullRequest

proc formatPullRequests(pullRequests: seq[PullRequest]): seq[string] =
  pullRequests.map(proc (pr: PullRequest): string =
    &"● <{pr.url}|(#{pr.number}) *{pr.title}*> ({pr.approvalCount} :thumbsup:)"
  )

proc outputMessage(pullRequests: seq[PullRequest],
    heading: string = ""): string =
  var message = formatPullRequests(pullRequests)
  if heading != "":
    message.insert(heading)

  return message.join("\n")

proc sendMessage*(pullRequests: seq[PullRequest], heading: string = "", channel: string, token: string): void =

  var j = %*{
    "channel": channel,
    "text": outputMessage(pullRequests, heading),
    "as_user": true
  }

  let bearer: string = fmt"Bearer {token}"
  let client = newHttpClient()
  client.headers = newHttpHeaders({"Authorization": bearer,
      "Content-type": "application/json"})

  discard client.post(url = "https://slack.com/api/chat.postMessage", body = $j)
