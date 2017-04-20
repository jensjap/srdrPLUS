document.addEventListener 'turbolinks:load', ->

  do ->

    Foundation.Abide.defaults.validators['minimum_length'] = ($el, required, parent) ->

      if !required
        return true
      fieldLength = $el.val().length
      minimumLength = $el.data('minimumLength')
      if fieldLength < minimumLength
        return false

      return

    return

  return
