{form, select, option, renderable, li, a, br, p, text, h3, h4, b, ul, css, span} = require 'teacup'
sprintf = require('util').format

utils = require './template-utils'

module.exports = renderable ({req, issues, users, allmilestones}) ->
  css 'app'
  h3 ->
    text issues.length + ' issues total'

  p ->
    form ->
      select name: 'milestone', onchange: 'this.form.submit()', -> 
        for milestone in allmilestones
          if milestone.number == parseInt req.session.milestone
            option selected: 'selected', value: milestone.number, milestone.title + " [" + milestone.open_issues + '] '
          else
            option value: milestone.number, milestone.title + " [" + milestone.open_issues + '] '
        if req.session.milestone?
          option value: 'ALL', 'All Milestones'
        else
          option selected: 'selected', value: 'ALL', 'All Milestones'

  utils.showusers req, '/milestones', users
  utils.showlabels req, '/milestones/', issues

  milestones = {}
  nostones = []

# separate by milestone (really, milestone title)

  for i in issues
    if i.milestone?
      milestones[i.milestone.title] ?= []
      milestones[i.milestone.title].push i
    else
      nostones.push i

  accum = {}
  
  for title in Object.keys(milestones).sort utils.datecompare
    milestones[title].sort utils.pricompare # sub-sort based on priority
    points = {}
    h4 'Milestone: ' + title
    ul ->
      for i in milestones[title]
        utils.issue i, points
    showPoints points
    accumulate accum, points
    
  if nostones.length > 0
    points = {}
    h4 'No milestone'
    ul ->
      for i in nostones
        utils.issue i, points
    showPoints points
    accumulate accum, points

  p "Estimated team capacity: 80 points/week"
  p "Estimated Lee capacity: 8029384023000 points/week"

  showPoints accum

accumulate = (accum, points) ->
  for login, pts of points
    accum[login] = 0 unless accum[login]
    accum[login] += pts

showPoints = (points) ->

  total = 0
  for login, pts of points
    total += pts
    
  devs = ""
  for dev, pts of points
    devs += dev + ": " + pts + " "
  text "Point total: " + total
  if total > 0
    text " (" + devs + ")"
