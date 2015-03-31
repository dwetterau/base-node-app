passport = require 'passport'

models = require '../models'

exports.post_user_create = (req, res) ->
  req.assert('username', 'Username must be at least 3 characters long.').len(3)
  req.assert('password', 'Password must be at least 4 characters long.').len(4)
  req.assert('confirm_password', 'Passwords do not match.').equals(req.body.password)
  errors = req.validationErrors()

  if errors
    req.flash 'errors', errors
    return res.redirect '/user/create'

  username = req.body.username
  password = req.body.password
  new_user = models.User.build({username})
  new_user.hash_and_set_password password, (err) ->
    if err?
      req.flash 'errors', {msg: "Unable to create account at this time"}
      return res.redirect '/user/create'
    else
      new_user.save().then ->
        req.logIn new_user, (err) ->
          req.flash 'success', {msg: 'Your account has been created!'}
          if err?
            req.flash 'info', {msg: "Could not automatically log you in at this time."}
          res.redirect '/'
      .catch ->
        req.flash 'errors', {msg: 'Username already in use!'}
        res.redirect '/user/create'

exports.post_user_login = (req, res, next) ->
  req.assert('username', 'Username is not valid.').notEmpty()
  req.assert('password', 'Password cannot be blank.').notEmpty()
  redirect = req.param('redirect')
  redirect_url = decodeURIComponent(redirect) || "/"

  errors = req.validationErrors()
  if errors?
    return res.send {ok: false, error: errors}

  passport.authenticate('local', (err, user, info) ->
    if err?
      return next(err)
    if not user
      return res.send {ok: false, error: 'Could not find user.'}
    req.logIn user, (err) ->
      if err?
        return next err

      res.send {ok: true, body: {redirect_url, user: user.to_json()}}
  )(req, res, next)

exports.get_user_logout = (req, res) ->
  req.logout()
  res.send {ok: true, body: {redirect_url: '/'}}

exports.post_change_password = (req, res) ->
  req.assert('old_password', 'Old password must be at least 4 characters long.').len(4)
  req.assert('new_password', 'New password must be at least 4 characters long.').len(4)
  req.assert('confirm_password', 'Passwords do not match.').equals(req.body.new_password)
  errors = req.validationErrors()

  if errors
    req.flash 'errors', errors
    return res.redirect '/user/password'

  old_password = req.body.old_password
  new_password = req.body.new_password

  fail = () ->
    req.flash 'errors', {msg: 'Failed to update password.'}
    return res.redirect '/user/password'

  models.User.find(req.user.id).then (user) ->
    user.compare_password old_password, (err, is_match) ->
      if not is_match or err
        req.flash 'errors', {msg: 'Current password incorrect.'}
        return fail();

      user.hash_and_set_password new_password, (err) ->
        if err?
          return fail()
        user.save().then () ->
          req.flash 'success', {msg: 'Password changed!'}
          res.redirect '/user/password'
        .catch fail
  .catch fail
