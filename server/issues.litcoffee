    https = require 'https'
    querystring = require 'querystring'
    async = require 'async'
    milestones = require './milestones'

    _ = require 'underscore'


Github treats multiple selected labels/filters as a conjunctive join.
We're going to do this disjunctively so we can see all the different
tickets in the various states.

These are the main repos for MAT.

    MATRepos = [
      'MobileAppTracking/tracking_engine'
      'MobileAppTracking/api'
      'MobileAppTracking/reporting'
      'MobileAppTracking/Dataflow'
      'MobileAppTracking/schema'
    ]

# Armageddon Report

Show the tickets to be done to avoid Armageddon (i.e. everything
labeled across these repos with 'armageddon').

    exports.armageddon = (user, token, res, req) ->

Every query will have the same access token and label.

      getOpenArmIssues = getRepoIssuesPreFiltered {access_token: token, labels: 'armageddon'}
      getClosedArmIssues = getRepoIssuesPreFiltered {access_token: token, state: 'closed', labels: 'armageddon'}
      async.concat MATRepos, getOpenArmIssues, (err, results) ->
        issues = results
        if req.params.user?
          issues = filterByUser results, req.params.user
        res.render 'armageddon', {issues: issues, users: issueUsers results}

# Milestones Report

Show the tickets to be done across repos for each milestone.

    exports.milestones = (user, token, res, req) ->
      queryToSession req

      labels = []
      for item, val of req.query
        if item.indexOf('label-') == 0
          labels.push item.replace /^label-/, ''
          
Every query will have the same access token and labels.

      isf = new IssueFilters MATRepos
      isf.joinParamList 'access_token', [token]
      if labels.length
        isf.joinParamList 'labels', [labels.toString()]
      if req.session.milestone? and req.session.milestone != 'ALL'
        isf.joinParamList 'milestone', parseInt req.session.milestone
      isf.issues (issues) ->
        milestones 'MobileAppTracking/api', token, (milestones) ->
          users = issueUsers issues
          if req.session.user?
            issues = filterByUser issues, req.session.user
          res.render 'milestones', {req: req, issues: issues, users: users, allmilestones: milestones}

## Issue finders

Take the existing list.  Take whatever filter is being added.  Do a
full cartesian product on it, return the resulting list.

    class IssueFilters

The initial call sets up the repos this thing will query.

      constructor: (@repos) ->
        
Given a parameter name and a list of values, add a separate repo query
for each.

      joinParamList: (name, list) =>
        results = []
        for item in list
          if @filters?
            for filter in @filters
              filter[name] = item
              results.push filter
          else
            i = {}
            i[name] = item
            results.push i
        @filters = results

      addIssues: (issues) ->
        for issue in issues
          @issues[issue.url] = issue
                                        
      getIssues: (repo, cb) =>
        query = (filter, cb) =>
          filter = querystring.stringify filter
          @doQuery repo, filter, (junk, issues) =>
            @addIssues issues
            cb '', issues
        async.concat @filters, query, cb

      doQuery: (repo, filter, cb) =>
        opts =
          host: "api.github.com"
          path: '/repos/' + repo + '/issues?' + filter
          method: "GET"

        request = https.request opts, (resp) ->
          data = ""
          resp.setEncoding 'utf8'
          resp.on 'data', (chunk) ->
            data += chunk;
          resp.on 'end', ->
            data = JSON.parse data
            if data.message?
              cb '', null
            else
              cb '', data
        request.end()

      issues: (cb) =>
        async.concat @repos, @getIssues, (err, junk) =>
          cb _.values @issues

This returns a curried function that'll query issues in the named repo
with the given fixed filters.

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
            data = JSON.parse data
            if data.message?
              cb '', null
            else
              cb '', data
        request.end()

Given a list of issues, return an array of the logins of all the users
that are assignees on those issues.

    issueUsers = (issues) ->
      userhash = {}
      for issue in issues
        if issue.assignee?
          userhash[issue.assignee.login] = 1
      users = []
      for user, n of userhash
        users.push user
      users

Given a list of issues, return an array of issues that are assigned to
this given user.

    filterByUser = (issues, user) ->
      filtered = []
      for issue in issues
        filtered.push issue if issue.assignee? and user == issue.assignee.login
      filtered

Take important options in the query string and put them into the session.

    queryToSession = (req) ->
      # User first
      if req.query.user?
        req.session.user = req.query.user
      if req.query.user == 'ALL' # Special, means no user in particular. 
        delete req.session.user
      # now milestone
      if req.query.milestone?
        req.session.milestone = req.query.milestone
      if req.query.milestone == 'ALL'
        delete req.session.milestone
