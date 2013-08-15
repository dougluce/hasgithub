    express = require 'express'
    http = require 'http'
    app = express()
    CoffeeScript = require 'coffee-script'
    teacup = require 'teacup'
    everyauth = require('everyauth')

    config =
      development:
        ghClientId: '6fa758b2f1d037fcb311'
        ghSecret: 'ca8e4785d95d181565effa3a056df83a2306c24f'
      production:
        ghClientId: '99561e4c5799754897da'
        ghSecret: 'fe0047c698edd16789940a5a544ab3ab889a76e4'

    connectConfig =
      src: 'public'
      jsDir: 'js'
      cssDir: 'css'
      jsCompilers: 
        litcoffee: 
          match: /\.js$/
          compileSync: (sourcePath, source) ->
            console.log "Compiling " + sourcePath
            CoffeeScript.compile source, filename: sourcePath, literate: true

    global.cdn_js = (url) ->
      teacup.js("#{js_libs_path}/#{url}")

    global.cdn_css = (url) ->
      teacup.css("#{css_libs_path}/#{url}")

    everyauth.github
      .appId(config[app.settings.env].ghClientId)
      .appSecret(config[app.settings.env].ghSecret)
      .scope('user,repo')
      .findOrCreateUser((session, accessToken, accessTokenExtra, githubUserMetadata) ->
        session.oauth = accessToken
        session.uid = githubUserMetadata.login)
      .redirectPath '/'

    everyauth.everymodule.handleLogout (req, res) ->
      req.logout()
      req.session.uid = null
      res.writeHead 303, { 'Location': this.logoutRedirectPath() }
      res.end()

    app.configure ->
      app.set 'views', __dirname + '/views'
      app.locals.pretty = true
      app.use express.bodyParser()
      app.use express.cookieParser()
      app.use express.session secret: 'super-duper-secret-secret'
      app.use express.methodOverride()
      app.engine "coffee", require('teacup/lib/express').renderFile
      app.use require('teacup/lib/connect-assets') connectConfig
      app.set 'view engine', 'coffee'
      app.use require('stylus').middleware src: __dirname + '/assets'
      app.use express.static __dirname + '/assets'
      app.use everyauth.middleware()
    
    app.configure 'production', ->
      app.set 'port', process.env.PORT
      global.js_libs_path = '//cdnjs.cloudflare.com/ajax/libs/'
      global.css_libs_path = '//cdnjs.cloudflare.com/ajax/libs/'

    app.configure 'development', ->
      app.set 'port', 33333
      global.js_libs_path = 'cdn'
      global.css_libs_path = 'cdn'
      app.use express.errorHandler()
    
    require('./server/router') app

    http.createServer(app).listen app.get('port'), ->
      console.log "HasGithub server listening on port " + app.get 'port'

    
