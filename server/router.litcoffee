    issues = require './issues'

    module.exports = (app) ->

The main page.

      app.get '/', (req, res) ->
        if req.session && req.session.uid
          return res.render 'index'
        res.render 'login'

      mapget app, '/sprint', issues.sprint
     
      app.get '/armageddon', (req, res) ->
        if !req.session.uid
          return res.redirect '/'
        issues.armageddon(req.session.uid, req.session.oauth, res)
     
      app.get '*', (req, res) ->
        res.status 404
        res.render '404', title: 'Page Not Found'

    mapget = (app, url, call)  ->
      app.get url, (req, res) ->
        if !req.session.uid
          return res.redirect '/'
        call req.session.uid, req.session.oauth, res