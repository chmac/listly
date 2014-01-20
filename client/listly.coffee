# Copy this into the client to create a collection client side
@Lists = new Meteor.Collection 'lists'

@Template.lists.lists = () ->
  Lists.find().fetch()

@Template.newItem.events
  'submit': (event) ->
    console.log "Form submitted by event %s", event.type
    Lists.update
      _id: 'YRtBGwSamQdotLr2p'
    ,
      $push:
        items:
          title: 'more new'
    event.preventDefault()