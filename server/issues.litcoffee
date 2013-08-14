    https = require 'https'
    querystring = require 'querystring'
    async = require 'async'

    repo = 'MobileAppTracking/tracking_engine'
    
Github treats multiple selected labels/filters as a conjunctive join.
We're going to do this disjunctively so we can see all the different
tickets in the various states.

These are the issues that are in development.

    currentIssueFilters = [
      {labels: 'development', state: 'open'}
    ]
      

These are the filters used for showing the issues that were pushed
during this last deployment.

    pushIssueFilters = [
      {labels: 'completed', state: 'closed'}
      {labels: 'complete - pending', state: 'closed'}
      {labels: 'complete - pending'}
      {labels: 'completed'}
      {labels: 'completed', state: 'closed'}
      {labels: 'production - review'}
    ]

A fixed milestone
                  
    milestone = 2
      
    exports.show = (user, token, res) ->

Every query will have the same access token and milestone.
            
      getIssues = getIssuesPreFiltered {access_token: token, milestone: milestone}
      async.concat currentIssueFilters, getIssues, (err, results) ->
        results.sort (a,b) -> a.number > b.number
        res.render 'sprint', {issues: results, token: token}

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
          path: '/repos/' + repo + '/issues?' + filters
          method: "GET"
  
        request = https.request opts, (resp) ->
          data = ""
          resp.setEncoding 'utf8'
          resp.on 'data', (chunk) ->
            data += chunk;
          resp.on 'end', ->
            cb '', JSON.parse data
        request.end()

