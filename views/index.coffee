{renderable, li, a, br, p, text} = require 'teacup'

module.exports = renderable ({issues, token}) ->
  for i in issues
    p ->
      text i.title
      br()
      a href: i.html_url, i.html_url
