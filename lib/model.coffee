# Copy this into the client to create a collection client side
@Lists = new Meteor.Collection 'lists'

# Expose some methods we can call from client or server
Meteor.methods
  unDone: (listId, itemId, done) ->
    check listId, String
    check itemId, String
    check done, Boolean
    
    # Get the list from the id
    lists = Lists.find({_id: listId}).fetch()
    list = lists[0]
    
    itemIndex = _.indexOf(_.pluck(list.items, 'id'), itemId)
    
    # If itemIndex is -1, then the item does not exist
    if itemIndex is -1
      throw new Meteor.Error 400, "No such item"
    
    # On the server, use items.$.done to set the data
    if Meteor.isServer
      Lists.update
        _id: listId
        'items.id': itemId
      ,
        $set:
          'items.$.done': done
    # Hack a workaround on the client
    else
      modifier = {$set: {}}
      modifier.$set['items.' + itemIndex + '.done'] = done
      Lists.update listId, modifier
