    https = require 'https'
    querystring = require 'querystring'
    async = require 'async'

Github treats multiple selected labels/filters as a conjunctive join.
We're going to do this disjunctively so we can see all the different
tickets in the various states.

These are the main repos for MAT.

    MATRepos = [
      'MobileAppTracking/tracking_engine'
      'MobileAppTracking/api'
      'MobileAppTracking/reporting'
      'MobileAppTracking/dataflow'
    ]

These are the issues that are in development.

    sprintIssueFilters = [
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
    sprintRepo = 'MobileAppTracking/tracking_engine'
      
    exports.sprint = (user, token, res) ->

Every query will have the same access token and milestone.
            
      getIssues = getIssuesPreFiltered {access_token: token, milestone: milestone}
      async.concat sprintIssueFilters, getIssues, (err, results) ->
        results.sort (a,b) -> a.number > b.number
        res.render 'sprint', {issues: results}

This returns a curried function that'll query issues with the fixed
filters while adding the filters given on each call.

    getIssuesPreFiltered = (fixedFilters) ->
      (filters, cb) ->
        for key, val of fixedFilters
          filters[key] = val
        filters = querystring.stringify filters
        opts =
          host: "api.github.com"
          path: '/repos/' + sprintRepo + '/issues?' + filters
          method: "GET"
  
        request = https.request opts, (resp) ->
          data = ""
          resp.setEncoding 'utf8'
          resp.on 'data', (chunk) ->
            data += chunk;
          resp.on 'end', ->
            cb '', JSON.parse data
        request.end()

The Armageddon Report.  Show the tickets to be done to avoid
Armageddon (i.e. everything labeled across these repos with
'armageddon').

    exports.armageddon = (user, token, res) ->

Every query will have the same access token and label.

      getArmIssues = getRepoIssuesPreFiltered {access_token: token, labels: 'armageddon'}
      async.concat MATRepos, getArmIssues, (err, results) ->
        res.render 'armageddon', {issues: results}

Milestones Report.  Show the tickets to be done across repos for each
milestone.

    exports.milestones = (user, token, res, req) ->

Every query will have the same access token and label.

      getIssues = getRepoIssuesPreFiltered {access_token: token, labels: 'development'}
      async.concat MATRepos, getIssues, (err, results) ->
        issues = []
        userhash = {}
        for issue in results
          if issue.assignee?
            userhash[issue.assignee.login] = 1
          if req.params.user?
            issues.push issue if issue.assignee? and req.params.user == issue.assignee.login
          else  
            issues.push issue
        users = []
        for user, n of userhash
          users.push user

        res.render 'milestones', {issues: issues, users: users}

This returns a curried function that'll query issues in the named repo
with the fixed filters while adding the filters given on each call.

    getRepoIssuesPreFiltered = (filters) ->
      filters = querystring.stringify filters
      (repo, cb) ->
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

