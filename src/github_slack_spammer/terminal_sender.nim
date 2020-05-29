import terminaltables
from ./github_grabber import PullRequest

let t = newUnicodeTable()
t.separateRows = false
t.setHeaders(@["#", "url", "title", "author", "Approvals"])

proc sendMessage*(pullRequests: seq[PullRequest]): void =
  for pr in pullRequests:
    t.addRow(@[$pr.number, pr.url, pr.title, pr.author, $pr.approvalCount])
  t.printTable
