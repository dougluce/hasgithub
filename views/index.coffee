{renderable, li, a, br, p, text, h3} = require 'teacup'

module.exports = renderable ({issues, token}) ->
  total = 0
  points = {}

  h3 ->
    text issues.length + ' issues'
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

    p ->
      text i.title
      br()
      text "Estimate: " + est + " points"
      text " Assignee: " + login
      br()
      a href: i.html_url, i.html_url
  p ->
    text "Total points: " + total
    
  for dev, pts of points
    p ->
      text "For " + dev + ": " + pts + " points"
