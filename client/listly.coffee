#//////// Helpers for in-place editing //////////

# Returns an event map that handles the "escape" and "return" keys and
# "blur" events on a text input (given by selector) and interprets them
# as "ok" or "cancel".
okCancelEvents = (selector, callbacks) ->
  ok = callbacks.ok or ->

  cancel = callbacks.cancel or ->

  events = {}
  events["keyup " + selector + ", keydown " + selector + ", focusout " + selector] = (evt) ->
    if evt.type is "keydown" and evt.which is 27
      
      # escape = cancel
      cancel.call this, evt
    else if evt.type is "keyup" and evt.which is 13 or evt.type is "focusout"
      
      # blur/return/enter = ok/submit if non-empty
      value = String(evt.target.value or "")
      if value
        ok.call this, value, evt
      else
        cancel.call this, evt

  events


Template.lists.lists = () ->
  # Return nothing if the user is not logged in
  if Meteor.userId() is null
    return []
  Lists.find
    $or: [
      'userId': Meteor.userId()
    ,
      'users._id': Meteor.userId()
    ]
  .fetch()

Template.lists.helpers
  checked: () ->
    if this.done then 'checked' else ''
  open: () ->
    if window.openPanel? and window.openPanel is this._id then 'in' else 'collapse'

Template.lists.events
  'change input[type=checkbox]': (event, template) ->
    listId = $(event.target).data('list-id')
    Meteor.call 'unDone', listId, this.id, event.target.checked
  'click .panel .panel-heading a': (event, template) ->
    if not jQuery(event.target).hasClass('collapsed')
      window.openPanel = this._id
  'click .delete': (event, template) ->
    Lists.remove this._id

Template.newItem.events
  'submit': (event, template) ->
    event.preventDefault()
    titleInput = template.find 'input'
    Lists.update
      _id: event.target.id
    ,
      $push:
        items:
          id: Random.id()
          title: titleInput.value
          done: false
    titleInput.value = ''

Template.newUserAccess.events
  'submit': (event, template) ->
    event.preventDefault()
    emailInput = template.find 'input'
    Meteor.call 'findUserIdByEmail', emailInput.value, (error, result) =>
      if result
        Lists.update
          _id: this._id
        ,
          $push:
            users:
              _.extend result, addedAt: new Date
        if Meteor.isClient
          FlashMessages.sendInfo 'User added to list.', {autoHide: true, hideDelay: 10000}
      else
        if Meteor.isClient
          FlashMessages.sendError 'User was not not found.', {autoHide: true, hideDelay: 10000}
    if Meteor.isClient
      emailInput.value = ''

# Create a new list when the new-list form is submitted
Template.newList.events
  'submit': (event, template) ->
    event.preventDefault()
    titleInput = template.find('input')
    Lists.insert
      title: titleInput.value
    titleInput.value = ''