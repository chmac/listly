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
  Lists.find().fetch()

Template.lists.helpers
  checked: () ->
    if this.done then 'checked' else ''

Template.lists.preserve
  'div.panel-collapse': (node) ->
    return node.id

Template.lists.events
  'change': (event, template) ->
    listId = $(event.target).data('list-id')
    Meteor.call 'unDone', listId, this.id, event.target.checked

Template.newItem.events
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

# Create a new list when the new-list form is submitted
Template.newList.events
  'submit': (event, template) ->
    event.preventDefault()
    titleInput = template.find('input')
    Lists.insert
      title: titleInput.value
    titleInput.value = ''