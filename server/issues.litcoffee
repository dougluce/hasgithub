    https = require 'https'
    querystring = require 'querystring'
    async = require 'async'

Github treats multiple selected labels/filters as a conjunctive join.
We're going to do this disjunctively so we can see all the different
tickets in the various states.

    issueFilters = [
      {labels: 'completed', state: 'closed'}
      {labels: 'complete - pending', state: 'closed'}
      {labels: 'complete - pending'}
      {labels: 'production - review'}
    ]

A fixed milestone
                  
    milestone = 1
      
    exports.show = (user, token, res) ->

Every query will have the same access token and milestone.
            
      getIssues = getIssuesPreFiltered {access_token: token, milestone: milestone}
      async.concat issueFilters, getIssues, (err, results) ->
        res.render 'index', {issues: results, token: token}

This returns a curried function that'll query issues with the fixed
filters while adding the filters given on each call.

    getIssuesPreFiltered = (fixedFilters) ->
      (filters, cb) ->
        for key, val of fixedFilters
          filters[key] = val
        label = encodeURIComponent label
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
            cb '', JSON.parse data
        request.end()

