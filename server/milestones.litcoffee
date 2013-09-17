    https = require 'https'

    module.exports = (repo, token, cb) ->
      opts =
        host: "api.github.com"
        path: '/repos/' + repo + '/milestones?access_token=' + token
        method: "GET"

      request = https.request opts, (resp) ->
        data = ""
        resp.setEncoding 'utf8'
        resp.on 'data', (chunk) ->
          data += chunk;
        resp.on 'end', ->
          cb JSON.parse data
      request.end()
