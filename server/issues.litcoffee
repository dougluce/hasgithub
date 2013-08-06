    gha = require "node-github"
    https = require 'https'
    querystring = require 'querystring'
    async = require 'async'

    issueFilters = [
      {labels: 'completed', state: 'closed'}
      {labels: 'complete - pending', state: 'closed'}
      {labels: 'complete - pending'}
      {labels: 'production - review'}
    ]
      
    milestone = 1
      
    exports.show = (user, token, res) ->
      getIssues = getIssuesPreFiltered {access_token: token, milestone: milestone}
      async.map issueFilters, getIssues, (err, results) ->
        accumulated = []
        for data in results
          data = JSON.parse data
          for item in data
            accumulated.push item
        res.render 'index', {issues: accumulated, token: token}

    getIssuesPreFiltered = (fixedFilters) ->
      (filters, cb) ->
        label = encodeURIComponent label
        for key,val of fixedFilters
          filters[key] = val
        filters = querystring.stringify filters
        opts =
          host: "api.github.com"
          path: '/repos/MobileAppTracking/tracking_engine/issues?' + filters
          method: "GET"
  
        request = https.request opts, (resp) ->
          data = ""
          resp.setEncoding 'utf8'
          resp.on 'data', (chunk) ->
            data += chunk;
          resp.on 'end', ->
            cb '', data
        request.end()

