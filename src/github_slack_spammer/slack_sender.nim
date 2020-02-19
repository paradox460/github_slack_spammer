import algorithm, httpclient, json, sequtils, strformat, strutils
import ./github_grabber


proc sendMessage*(text: string, channel: string, token: string): void =
  var j = %*{
    "channel": channel,
    "text": text,
    "as_user": true
  }

  let bearer: string = fmt"Bearer {token}"
  let client = newHttpClient()
  client.headers = newHttpHeaders({"Authorization": bearer,
      "Content-type": "application/json"})

  discard client.post(url = "https://slack.com/api/chat.postMessage", body = $j)

proc formatPullRequests(pullRequests: seq[PullRequest]): seq[string] =
  pullRequests.sorted(cmp = proc (pr_a, pr_b: PullRequest): int =
    result = cmp(pr_a.approvalCount, pr_b.approvalCount)
    if result == 0:
      result = cmp(pr_a.number, pr_b.number)
  ).map(proc (pr: PullRequest): string =
    &"● <{pr.url}|(#{pr.number}) *{pr.title}*> ({pr.approvalCount} :thumbsup:)"
  )

proc outputMessage*(pullRequests: seq[PullRequest],
    header: string = ""): string =
  var message = formatPullRequests(pullRequests)
  if header != "":
    message.insert(header)

  return message.join("\n")
