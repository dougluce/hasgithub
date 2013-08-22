{renderable, li, a, br, p, text, h3, h4, b, ul, css, span} = require 'teacup'
sprintf = require('util').format
utils = require './template-utils'

module.exports = renderable ({issues, users}) ->
  total = 0
  points = {}

  css 'app'

  h3 ->
    text issues.length + ' issues to avoid Armageddon'

  utils.showusers '/armageddon/', users

  milestones = {}
  nostones = []

# separate by milestone

  for i in issues
    console.log i
    if i.milestone?
      milestones[i.milestone.title] ?= []
      milestones[i.milestone.title].push i
    else
      nostones.push i

# show state

  stones = (key for key, issues of milestones)

  stones.sort utils.datesort
  
  for stone in stones
    h4 'Milestone: ' + stone
    ul ->
      for i in milestones[stone]
        utils.issue i

  if nostones.length > 0
    h4 'No milestone'
    ul ->
      for i in nostones
        utils.issue i
