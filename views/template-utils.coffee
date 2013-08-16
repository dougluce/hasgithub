{li, a, br, text, b, span} = require 'teacup'
sprintf = require('util').format

exports.issue = (i, repo = null) ->
  login = "Unassigned"
  if !repo? and repo = i.html_url.match /https:\/\/github.com\/\S+\/(\S+)\/issues/
    repo = repo[1]
  
  if i.assignee
    login = i.assignee.login
  li ->
    b ->
      text sprintf "%s:#%d: ", repo, i.number
      a href: i.html_url, i.title
    if est = i.body.match /Estimate: (\d+)/
      est = est[1]
      br()
      text "Points: " + est + " points"

    br()
    text "Assignee: " + login + " "
    exports.labels i

exports.labels = (i) ->
  span '.labels', ->
    for label in i.labels
      span '.label', style: "background-color: #" + label.color, label.name

priority = (issue) ->
  for l in issue.labels
    if pri = l.name.match /priority (\d+)/
      return pri[1]
  return 9999

exports.prisort = (a,b) ->
  return -1 if priority(a) < priority(b)
  return 1 if priority(a) > priority(b)
  return 0

exports.datesort = (a,b) ->
  a = new Date(a)
  b = new Date(b)
  return -1 if a<b
  return 1 if a>b
  return 0

exports.showusers = (repo, users) ->
  for user in users
    a href: repo + user, user
    text ' '
  a href: repo, 'all'
   
