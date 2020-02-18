import httpclient, json, sequtils, strformat, times

let graphQLRequest = """
query($owner: String!, $repo: String!, $labels: [String!]) {
  repository(owner: $owner, name: $repo) {
    pullRequests(states: OPEN, labels: $labels, orderBy: {field: CREATED_AT, direction: DESC}, first: 50 ) {
      edges {
        node {
          author {
            login
          }
          title
          number
          url
          createdAt
          projectCards(first: 5) {
            edges {
              node {
                project {
                  number
                }
              }
            }
          }
          reviews(first: 5, states: [APPROVED, CHANGES_REQUESTED]) {
            edges {
              node {
                author {
                  login
                }
                state
              }
            }
          }
        }
      }
    }
  }
}
"""

type PullRequest* =
  tuple[
    author: string,
    number: int,
    title: string,
    url: string,
    createdAt: DateTime,
    projects: seq[int],
    approvalCount: int,
    rejectedCount: int
  ]

proc parsePullRequest(rawPullRequest: JsonNode): PullRequest =
  let parsedProjects: seq[int] = rawPullRequest{"projectCards",
      "edges"}.getElems.map(proc(node: JsonNode): int =
    node{"node", "project", "number"}.getInt
  )

  var approvalCount, rejectedCount: int = 0

  for node in rawPullRequest{"reviews", "edges"}.items:
    let state = node{"node", "state"}.getStr
    if state == "APPROVED":
      approvalCount += 1
    elif state == "CHANGES_REQUESTED":
      rejectedCount += 1

  result = (
    author: rawPullRequest{"author", "login"}.getStr,
    number: rawPullRequest{"number"}.getInt,
    title: rawPullRequest{"title"}.getStr,
    url: rawPullRequest{"url"}.getStr,
    createdAt: times.parse(rawPullRequest{"createdAt"}.getStr,
        "yyyy-MM-dd'T'hh:mm:ss'Z'", utc()),
    projects: parsedProjects,
    approvalCount: approvalCount,
    rejectedCount: rejectedCount
  )

proc getPullRequests*(owner: string, repo: string, labels: seq[string],
    token: string): seq[PullRequest] =
  var body = %* {
    "query": graphQLRequest,
    "variables": {
      "owner": owner,
      "repo": repo,
      "labels": if labels.len == 0:
        newJNull()
      else:
        %labels
    }
  }

  let bearer: string = fmt"Bearer {token}"
  let client = newHttpClient()
  client.headers = newHttpHeaders({"Authorization": bearer,
      "Content-type": "application/json"})


  var response = client.post(url = "https://api.github.com/graphql", body = $body)
  if response.code != Http200:
    raise newException(HttpRequestError,
        fmt"Github fetch returned code {response.code}")
  return response.body.parseJson{"data", "repository", "pullRequests",
      "edges"}.getElems.map(proc(node: JsonNode): PullRequest =
    node{"node"}.parsePullRequest()
  )

proc filterByProject*(pullRequests: seq[PullRequest], projectIds: seq[
    int]): seq[PullRequest] =
  filter(pullRequests, proc (pr: PullRequest): bool =
    projectIds.any(proc (projectId: int): bool = projectId in pr.projects)
  )

proc filterApproved*(pullRequests: seq[PullRequest],
    approvalThreshold: int = 2): seq[PullRequest] =
  filter(pullRequests, proc (pr: PullRequest): bool =
    pr.rejectedCount == 0 and pr.approvalCount < approvalThreshold
  )
