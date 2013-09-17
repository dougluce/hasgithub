    issues = require './issues'

    module.exports = (app) ->

The main page.

      mapget app, '/', (uid, oauth, res, req) ->
        res.render 'index'

      app.get '/', (req, res) ->
        if req.session && req.session.uid
          return res.render 'index'
        res.redirect '/auth/github'

      mapget app, '/sprint', issues.sprint
      mapget app, '/milestones/:user', issues.milestones
      mapget app, '/milestones', issues.milestones
      mapget app, '/armageddon/:user', issues.armageddon
      mapget app, '/armageddon', issues.armageddon

      app.get '*', (req, res) ->
        res.status 404
        res.render '404', title: 'Page Not Found'

    mapget = (app, url, call)  ->
      app.get url, (req, res) ->
        if !req.session.uid
          req.session.redirectTo = url
          return res.redirect '/auth/github'
        call req.session.uid, req.session.oauth, res, req
