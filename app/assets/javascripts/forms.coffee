document.addEventListener 'DOMContentLoaded', ->
  return if $( '.extractions.work' ).length > 0
  documentCode()

document.addEventListener 'extractionSectionLoaded', ->
  documentCode()

documentCode = ->
  Foundation.Abide.defaults.validators['minimum_length'] = ( $el, required, parent ) ->
    if !required
      return true
    fieldLength = $el.val().length
    minimumLength = $el.data( 'minimumLength' )
    if fieldLength < minimumLength
      return false
    return