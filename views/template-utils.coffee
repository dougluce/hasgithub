{label, li, a, br, text, b, span, div, input, form} = require 'teacup'
sprintf = require('util').format

exports.issue = (i, points, repo = null, extra = true) ->
  login = "Unassigned"
  if !repo? and repo = i.html_url.match /https:\/\/github.com\/\S+\/(\S+)\/issues/
    repo = repo[1]
  
  if i.assignee
    login = i.assignee.login
  li ->
    b ->
      if extra
        text sprintf "%s:#%d: ", repo, i.number
      else
        text sprintf "#%d: ", i.number
      a href: i.html_url, i.title
    if extra and est = exports.estimate i
      br()
      text "Points: " + est + " points"
      points[login] = 0 unless points[login]
      points[login] += parseInt(est)

    br()
    if extra
      text "State: " + i.state  + " "
      text "Assignee: " + login + " "
      exports.labels i
    return points

exports.estimate = (issue) ->
  if est = issue.body.match /Estimate: (\d+)/
    return est[1]

exports.labels = (i) ->
  span '.labels', ->
    for ghlabel in i.labels
      span '.label', style: "background-color: #" + ghlabel.color, ghlabel.name

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

exports.showusers = (req, viewname, users) ->
  for user in users
    if req.session.user? and user == req.session.user
      b user
    else
      a href: viewname + '?user=' + user, user
    text ' '
  a href: viewname + '?user=ALL', 'all'
   
exports.showlabels = (req, viewname, issues) ->
  labels = {}
  for issue in issues
    for ghlabel in issue.labels
      labels[ghlabel.name] = ghlabel.color

  form '.labels', ->
    for name, color of labels
      checked = req.session.labels? and name in req.session.labels
      label ->
        input type: 'checkbox', name: 'label-' + name, style: "background-color: #" + color, checked: checked
        text name
    input type: 'submit', value: 'Refresh', name: 'refreshlabels'
