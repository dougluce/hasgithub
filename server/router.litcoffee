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
        issues.show(req.session.uid, req.session.oauth, res)
     
      app.get '*', (req, res) ->
        res.status 404
        res.render '404', title: 'Page Not Found'

