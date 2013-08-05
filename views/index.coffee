{renderable, div, h1, a, br, p} = require 'teacup'

module.exports = renderable ({username, repos}) ->
  a href: '/auth/github', 'sign in with github'

  p 'hey there ' + username + '!'
  br
  br
  p 'your repos:'
  for repo in repos
    p ->
      a href: repo.url, repo.name
      br
      p repo.description
