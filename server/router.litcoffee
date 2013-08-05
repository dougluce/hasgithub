    module.exports = (app) ->

The main page.

      app.get '/', (req, res) ->
        res.render 'index', username: 'bob', repos: [{url: 'a', name: 'b'}]
  
      app.get '*', (req, res) -> 
        res.status 404
        res.render '404', title: 'Page Not Found'
