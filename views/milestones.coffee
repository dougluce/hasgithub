{renderable, li, a, br, p, text, h3, h4, b, ul, css, span} = require 'teacup'
sprintf = require('util').format

utils = require './template-utils'

module.exports = renderable ({issues, users}) ->
  total = 0
  points = {}

  css 'app'

  h3 ->
    text issues.length + ' issues in development across all repos'

  utils.showusers '/milestones/', users

  milestones = {}
  nostones = []

# separate by milestone

  for i in issues
    if i.milestone?
      milestones[i.milestone.title] ?= []
      milestones[i.milestone.title].push i
    else
      nostones.push i

  stones = (key for key, issues of milestones)
  stones.sort utils.datesort

  for stone in stones
    milestones[stone].sort utils.prisort # sub-sort based on priority
    h4 'Milestone: ' + stone
    ul ->
      for i in milestones[stone]
        utils.issue i

  if nostones.length > 0
    h4 'No milestone'
    ul ->
      for i in nostones
        utils.issue i
