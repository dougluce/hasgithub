    https = require 'https'

    module.exports = (app) ->

The main page.

      app.get '/', (req, res) ->
        if req.session && req.session.uid
          res.redirect '/index'
        res.render 'login'

      app.get '/index', (req, res) ->
        if !req.session.uid
          return res.redirect '/'
        token = '?access_token=' + req.session.oauth
        opts = 
          host: "api.github.com"
          path: '/user/repos' + token
          method: "GET"
      
        request = https.request opts, (resp) ->
          data = ""
          resp.setEncoding 'utf8'
          resp.on 'data', (chunk) ->
            data += chunk;
          resp.on 'end', ->
            repos = JSON.parse(data);
            res.render 'index', {username: req.session.uid, repos: repos, token: token}
        request.end()
    
      app.get '*', (req, res) ->
        res.status 404
        res.render '404', title: 'Page Not Found'

