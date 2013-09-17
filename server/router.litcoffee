    issues = require './issues'

    module.exports = (app) ->

Make it easy to redirect if we're not logged in.

      mapget = (url, call)  ->
        app.get url, (req, res) ->
          if !req.session.uid
            req.session.redirectTo = url
            return res.redirect '/auth/github'
          call req.session.uid, req.session.oauth, res, req

The main page.

      mapget '/', (uid, oauth, res, req) ->
        res.render 'index'

      mapget '/sprint', issues.sprint
      mapget '/milestones/:user', issues.milestones
      mapget '/milestones', issues.milestones
      mapget '/armageddon/:user', issues.armageddon
      mapget '/armageddon', issues.armageddon

      app.get '*', (req, res) ->
        res.status 404
        res.render '404', title: 'Page Not Found'

