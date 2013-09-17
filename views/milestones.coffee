{form, select, option, renderable, li, a, br, p, text, h3, h4, b, ul, css, span} = require 'teacup'
sprintf = require('util').format

utils = require './template-utils'

module.exports = renderable ({req, issues, users, allmilestones}) ->
  css 'app'
  h3 ->
    text issues.length + ' issues across all repos'

  p ->
    form ->
      select name: 'milestone', onchange: 'this.form.submit()', -> 
        for milestone in allmilestones
          option value: milestone.number, milestone.title + " [" + milestone.open_issues + '] '
        option value: 'ALL', 'All Milestones'

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

  for title in Object.keys(milestones).sort utils.datesort
    milestones[title].sort utils.prisort # sub-sort based on priority
    h4 'Milestone: ' + title
    ul ->
      for i in milestones[title]
        utils.issue i

  if nostones.length > 0
    h4 'No milestone'
    ul ->
      for i in nostones
        utils.issue i
