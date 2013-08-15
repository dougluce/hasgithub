{renderable, li, a, br, p, text, h3, h4, b, ul, css, span} = require 'teacup'
sprintf = require('util').format

issue = (i) ->
  login = "Unassigned"
  if repo = i.html_url.match /https:\/\/github.com\/\S+\/(\S+)\/issues/
    repo = repo[1]
  
  if i.assignee
    login = i.assignee.login

  li ->
    b ->
      text sprintf "%s:#%d: ", repo, i.number
      a href: i.html_url, i.title
    br()
    text "Assignee: " + login
    br()
    labels i

labels = (i) ->
  span '.labels', ->
    for label in i.labels
      span '.label', style: "background-color: #" + label.color, label.name

module.exports = renderable ({issues, users}) ->
  total = 0
  points = {}

  css 'app'

  h3 ->
    text issues.length + ' issues in development across all repos'

  for user in users
    a href: '/milestones/' + user, user
    text ' '

  a href: '/milestones', 'all'
   
  milestones = {}
  nostones = []
# separate by milestone
  for i in issues
    if i.milestone?
      milestones[i.milestone.title] ?= []
      milestones[i.milestone.title].push i
    else
      nostones.push i

# show state
# 
  stones = (key for key, issues of milestones)

  stones.sort (a,b) ->
    a = new Date(a)
    b = new Date(b)
    return -1 if a<b
    return 1 if a>b
    return 0

# sub-sort based on priority
  priority = (issue) ->
    for l in issue.labels
      if pri = l.name.match /priority (\d+)/
        return pri[1]
    return 9999

  for stone in stones
    milestones[stone].sort (a,b) ->
      return -1 if priority(a) < priority(b)
      return 1 if priority(a) > priority(b)
      return 0
    
  for stone in stones
    h4 'Milestone: ' + stone
    ul ->
      for i in milestones[stone]
        issue i

  if nostones.length > 0
    h4 'No milestone'
    ul ->
      for i in nostones
        issue i
