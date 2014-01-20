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


# Copy this into the client to create a collection client side
@Lists = new Meteor.Collection 'lists'

@Template.lists.lists = () ->
  Lists.find().fetch()

@Template.newItem.events
  'submit': (event, template) ->
    event.preventDefault()
    titleInput = template.find('input')
    Lists.update
      _id: event.target.id
    ,
      $push:
        items:
          id: Random.id()
          title: titleInput.value
          done: false
    titleInput.value = ''

@Template.lists.events
  'change': (event, template) ->
    console.log 
