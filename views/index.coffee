{renderable, li, a, br, p, text, h3, b, ul} = require 'teacup'

module.exports = renderable ->
  a href: '/armageddon', "Avoiding Armageddon issues"
  br()
  a href: '/milestones', "Issues in development by milestone"
  br()
  a href: '/sprint', "Sprint planner"
  
