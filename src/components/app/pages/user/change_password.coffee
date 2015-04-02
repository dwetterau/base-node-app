React = require 'react'
FormPage = require './form_page'
Notifier = require '../../utils/notifier'

ChangePassword = React.createClass

  _onSubmit: (fields) ->
    $.post('/user/password', fields).done (response) =>
      if response.ok
        Notifier.info 'Password changed!'
        @_clearFields fields
      else
        if typeof response.error == 'object'
          for error in response.error
            Notifier.error error.msg
        else
          Notifier.error response.error

    .fail Notifier.error

  _clearFields: (fields) ->
    for field of fields
      $('#' + field).val ''

  render: () ->
    React.createElement FormPage,
      pageHeader: 'Change Password'
      action: '/user/password'
      inputs: [
        {
          type: "password"
          name: "old_password"
          key: "old_password"
          id: "old_password"
          floatingLabelText: "Old Password"
          autofocus: true
        }, {
          type: "password"
          name: "new_password"
          key: "new_password"
          id: "new_password"
          floatingLabelText: "New Password"
        }, {
          type: "password"
          name: "confirm_password"
          key: "confirm_password"
          id: "confirm_password"
          floatingLabelText: "Confirm Password"
        }
      ]
      submitLabel: 'Change password'
      onSubmit: @_onSubmit

module.exports = ChangePassword
