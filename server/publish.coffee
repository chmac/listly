# Lists -- {name: String}
@Lists = new Meteor.Collection 'lists'

## Publish complete set of lists to all clients.
#Meteor.publish 'lists', () ->
#  @Lists.find()
