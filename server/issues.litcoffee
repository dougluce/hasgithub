    https = require 'https'
    querystring = require 'querystring'
    async = require 'async'
    _ = require 'underscore'
    milestones = require './milestones'

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

# Milestones Report

Show the tickets to be done across repos for each milestone.

    exports.milestones = (user, token, res, req) ->
      queryToSession req

Every query will have the same access token

      isf = new IssueFilters MATRepos
      isf.addConjunction 'access_token', token
      if req.session.labels? # Show any ticket with any of these labels.
        for label in req.session.labels
          isf.addDisjunction 'labels', label
      if req.session.milestone? and req.session.milestone != 'ALL'
        isf.addDisjunction 'milestone', parseInt req.session.milestone
      isf.issues (issues) ->
        milestones 'MobileAppTracking/api', token, (milestones) ->
          users = issueUsers issues
          if req.session.user?
            issues = filterByUser issues, req.session.user
          res.render 'milestones', {req: req, issues: issues, users: users, allmilestones: milestones}

# Release Report

This shows the issues that are part of a particular milestone.  For
handy copy/paste when sending out release report emails.

    exports.report = (user, token, res, req) ->
      queryToSession req
      isf = new IssueFilters ['MobileAppTracking/api']
      isf.addConjunction 'access_token', token
      if req.session.labels?
        for label in req.session.labels
          isf.addDisjunction 'labels', label
      if req.session.milestone? and req.session.milestone != 'ALL'
        isf.addDisjunction 'milestone', [parseInt req.session.milestone]
      isf.issues (issues) ->
        milestones 'MobileAppTracking/api', token, (milestones) ->
          users = issueUsers issues
          if req.session.user?
            issues = filterByUser issues, req.session.user
          res.render 'report', {req: req, issues: issues, users: users, allmilestones: milestones}

# Estimated tickets.

This shows the issues that have estimates on them.

    exports.estimated = (user, token, res, req) ->
      queryToSession req

Every query will have the same access token and labels.

      isf = new IssueFilters ['MobileAppTracking/api']
      isf.addConjunction 'access_token', token
      isf.issues (issues) ->
        issues = issues.filter (i) -> estimate(i)?
        milestones 'MobileAppTracking/api', token, (milestones) ->
          users = issueUsers issues
          res.render 'milestones', {req: req, issues: issues, users: users, allmilestones: milestones}

## Issue time estimate

Give the estimate that's hidden within a comment in the body of this
issue.

    estimate = (issue) ->
      if est = issue.body.match /Estimate: (\d+)/
        return est[1]


## Issue finders

We have two different kinds of things we filter on when querying the
issue list.  The first are the conjunctive filters.  All queries get
this filter.  We can limit which milestones we query for, which users,
and add things every query needs like auth info.

The second are the disjunctive filters.  Each of these filters results
in a new query.  Each of those queries takes all the conjunctive
filters and adds the disjunctive filter.  This lets us do things like
"OR" style queries across labels, milestones, or users.

The resulting query is make unique based on the issue number within
the particular repo.

    class IssueFilters

The initial call sets up the repos we'll query.

      constructor: (@repos) ->
        @conjunctiveFilters = {}
        @disjunctiveFilters = []

Add a conjunctive filter.

      addConjunction: (name, value) =>
        @conjunctiveFilters[name] = value

Add a disjunctive filter.

      addDisjunction: (name, value) =>
        filter = {}
        filter[name] = value
        @disjunctiveFilters.push filter

Add the retrieved issues to our current set.  Disregard any repeated issues.

      addIssues: (issues) =>
        for issue in issues
          @issues[issue.url] = issue

Get issues from a repo.  Will go over all the existing filters, and
query the repo once for each filter.  Issues returned are added to the
list.

      getIssues: (repo, cb) =>
        query = (filter, cb) =>
          qf = _.extend _.clone(@conjunctiveFilters), filter
          @doQuery repo, qf, (issues) =>
            @addIssues issues if issues?
            cb()
        if @disjunctiveFilters.length>0
          async.each @disjunctiveFilters, query, cb
        else # No filters, do query with only conjunctive.
          query [], cb

Query a single repo with a single filter, sending the received list of
issues to the callback.

      doQuery: (repo, filter, cb) =>
        opts =
          host: "api.github.com"
          path: '/repos/' + repo + '/issues?' + querystring.stringify filter

        request = https.request opts, (resp) ->
          data = ""
          resp.on 'data', (chunk) ->
            data += chunk;
          resp.on 'end', ->
            data = JSON.parse data
            cb if data.message? then null else data
        request.end()

Get the issues for this object.  Call this after setting up all the filter combinations you want.

      issues: (cb) =>
        async.each @repos, @getIssues, (err) =>
          cb _.values @issues

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
        
      # And now, the labels.
      if req.query.refreshlabels?
        labels = []
        for item, val of req.query
          if item.indexOf('label-') == 0
            label = item.replace /^label-/, ''
            labels.push label
        req.session.labels = labels
