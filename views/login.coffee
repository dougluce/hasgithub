{renderable, a} = require 'teacup'

module.exports = renderable ({username, repos}) ->
  a href: '/auth/github', 'sign in with github'

