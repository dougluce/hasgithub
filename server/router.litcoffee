    issues = require './issues'

    module.exports = (app) ->

The main page.

      app.get '/', (req, res) ->
        if req.session && req.session.uid
          res.redirect '/sprint'
        res.render 'login'

      app.get '/sprint', (req, res) ->
        if !req.session.uid
          return res.redirect '/'
        issues.sprint(req.session.uid, req.session.oauth, res)
     
      app.get '/armageddon', (req, res) ->
        if !req.session.uid
          return res.redirect '/'
        issues.armageddon(req.session.uid, req.session.oauth, res)
     
      app.get '*', (req, res) ->
        res.status 404
        res.render '404', title: 'Page Not Found'

    authcall = (req, res, call) ->
      if !req.session.uid
        return res.redirect '/'
      call()      