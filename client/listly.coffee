# Copy this into the client to create a collection client side
@Lists = new Meteor.Collection 'lists'

@Template.lists.lists = () ->
  Lists.find().fetch()