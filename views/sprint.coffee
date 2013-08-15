{renderable, li, a, br, p, text, h3, b, ul} = require 'teacup'
sprintf = require('util').format

module.exports = renderable ({issues}) ->
  total = 0
  points = {}

  h3 ->
    text issues.length + ' issues due for 8/20/2013 '

  ul ->
    for i in issues

      if est = i.body.match /Estimate: (\d+)/
        est = est[1]
      else est = 0
      total += parseInt(est)
      login = "Unassigned"
      if i.assignee
        login = i.assignee.login
      points[login] = 0 unless points[login]
      points[login] += parseInt(est)

      li ->
        b ->
          a href: i.html_url, sprintf "#%d: %s", i.number, i.title
        br()
        text "Points: " + est + " points"
        br()
        text "Assignee: " + login
  p ->
    text "Total points: " + total

  h3 'Per-dev point assignments'
  ul ->
    for dev, pts of points
      li "For " + dev + ": " + pts + " points"
  p "Estimated team capacity: 80 points/week"
  p "Estimated Lee capacity: 8029384023000 points/week"
