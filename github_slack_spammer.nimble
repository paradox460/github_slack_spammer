# Package

version       = "0.1.1"
author        = "Jeff Sandberg"
description   = "A tool for spamming open PRs into slack"
license       = "MIT"
srcDir        = "src"
skipExt       = @["nim"]
binDir        = "bin/"
bin           = @["github_slack_spammer"]

# Dependencies

requires "nim >= 0.20.2", "cligen >= 0.9.42 & < 10"

task upx, "Build minified binary":
  let args = "nimble build -d:release"
  exec args

  if findExe("upx") != "":
    echo "Running `upx --best`"
    exec "upx --best bin/github_slack_spammer"
