{renderable, li, a, br, p, text, h3, b, ul} = require 'teacup'

module.exports = renderable ->
  a href: '/milestones', "Issues in development by milestone"
  a href: '/report', "Release report"
  
