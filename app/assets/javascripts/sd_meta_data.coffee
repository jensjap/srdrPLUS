# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class Timekeeper
  @_timer_dict: {}

  @create_timer_for_form: ( form ) -> 
    formId = form.getAttribute( 'id' )
    if formId of @_timer_dict
      clearTimeout( @_timer_dict[formId] )
    @_timer_dict[ formId ] = setTimeout -> 
      validate_and_send_async_form( form )
    , 375
    @_timer_dict[ formId ] 

class StatusChecker
  @input_empty: ( input ) ->
    return !$( input ).val()

  @get_all_inputs: ( ) ->
    return $( 'input:not(.select2-search__field), select, textarea' )

  @check_status: ( ) ->
    for elem in StatusChecker.get_all_inputs()
      if StatusChecker.input_empty( elem )
        return false
    return true

  @highlight_empty: ( ) ->
    completeable = true
    for elem in StatusChecker.get_all_inputs()
      if StatusChecker.input_empty( elem )
        completeable = false
        $( elem ).addClass( 'empty-input' )
    return completeable

validate_and_send_async_form = ( form ) ->
  if not validate_form_inputs( form )
    return
  $( '.preview-button' ).attr( 'disabled', '' )
  send_async_form( form )

# Set the field to display from the result set.
formatResultSelection = ( result, container ) ->
  result.text

# returns validation status of form
# also adds the class invalid to form inputs failing validation
validate_form_inputs = ( form ) ->
  $form = $( form )
  $form.find( '.invalid-url' ).removeClass( 'invalid-url' )
  is_form_valid = true
  # validate url inputs
  for input_elem in $form.find( '.url-input' )
    $input_elem = $( input_elem )
    input_val = $input_elem.val() || ""
    is_input_valid = true
    if not (input_val == "")
      valid_href = get_valid_URL( input_val )
      if not valid_href
        https_appended_val = "https://" + input_val
        valid_href = get_valid_URL( https_appended_val )
        if not valid_href
          $input_elem.parents('div.input').addClass( 'invalid-url' ) 
          is_input_valid = false
        else
          $input_elem.val( valid_href )
    is_form_valid = is_form_valid && is_input_valid
  return is_form_valid

# Markup result.
formatResult = ( result ) ->
  if result.loading
    return result.text
  markup = '<span>'
  if ~result.text.indexOf 'Pirate'
    markup += '<img src=\'https://s-media-cache-ak0.pinimg.com/originals/01/ee/fe/01eefe3662a40757d082404a19bce33b.png\' alt=\'pirate flag\' height=\'32\' width=\'32\'> '
  if ~result.text.indexOf 'New item: '
    #!!! Maybe add some styling.
    markup += ''
  markup += result.text
  if result.suggestion
    markup += ' (suggested by ' + result.suggestion.first_name + ')'
  markup += '</span>'
  markup

# initiates select2 dropdowns
init_select2 = (selector, url) ->
  $( selector ).select2
    selectOnClose: true, # use TAB and ESC to select
    minimumInputLength: 0,
    placeholder: '-- Select or type other value --', # This wording is ambiguous
    ajax:
      url: url,
      dataType: 'json'
      delay: 250
      data: ( params ) ->
        q: params.term
        page: params.page
      processResults: ( data, params ) ->
        # The server may respond with params.page, set it to 1 if not.
        params.page = params.page || 1
        results: $.map( data.items, ( i ) ->
          id: i.id
          text: i.name
          suggestion: i.suggestion
        )
    escapeMarkup: ( markup ) ->
      markup
    templateResult: formatResult
    templateSelection: formatResultSelection

apply_all_select2 =() ->
  init_select2("#sd_meta_datum_funding_source_ids", '/funding_sources')
  init_select2("#sd_meta_datum_key_question_type_ids", '/key_question_types')
  init_select2(".sd_search_database", '/sd_search_databases')
  init_select2(".key_question", '/key_questions')
  init_select2(".key_question_type", '/key_question_types')
  sd_meta_datum_id = $(".sd_picods_key_question").data('sd-meta-datum-id')
  init_select2(".sd_picods_key_question", "/sd_key_questions?sd_meta_datum_id=" + sd_meta_datum_id)
  init_select2(".sd_picods_type", '/sd_picods_types')
  init_select2(".review_type", '/review_types')
  init_select2(".data_analysis_level", '/data_analysis_levels')

  $( '.apply-select2' ).select2( placeholder: '-- Select or type other value --' )
  $( '.sd-outcome-select2' ).select2({ tags: true, placeholder: '-- Select or type other value --' })

add_form_listeners =( form ) ->
  $form = $( form )
  # Use this to keep track of the different timers.
  formId = $form.attr( 'id' )
  
  $form.find( 'select, input[type="file"]' ).on 'change', ( e ) ->
    e.preventDefault()
    # Mark form as 'dirty'.
    $form.addClass( 'dirty' )
    Timekeeper.create_timer_for_form $form[0]

  $form.on 'cocoon:after-insert cocoon:after-remove', ( e ) ->
    # Mark form as 'dirty'.
    $form.addClass( 'dirty' )
    Timekeeper.create_timer_for_form $form[0]

  $( "a.remove-figure[data-remote]" ).on "ajax:success",  ( event ) ->
    $( this ).parent().closest( 'div' ).fadeOut();

  # Text Field.
  $form.find('input[type="text"], textarea').keyup ( e ) ->
    e.preventDefault()

    # Ignore 'keyup' for a list of keys.
    code = e.keyCode || e.which;
    # 9: tab; 16: shift; 37: left-arrow; 38: up-arrow; 39: right-arrow; 40: down-arrow; 18: option; 91: cmd
    if code in [9, 16, 18, 37, 38, 39, 40, 91]
      return

    # Mark form as 'dirty'.
    $form.addClass( 'dirty' )
    Timekeeper.create_timer_for_form $form[0]

bind_srdr20_saving_mechanism = () ->
  $( 'form.sd-form' ).each ( i, form ) ->
    add_form_listeners( form )
    $cocoon_container = $( form ).parents( '.cocoon-container' )
    $cocoon_container.on 'sd:form-loaded', ( e ) ->
      add_form_listeners( $cocoon_container.children( 'form' ) )
      apply_all_select2()
  
updateSectionFlag = (domEl) ->
  sectionId = domEl.id[0]
  #var sectionId = domEl.getAttribute('statusable-id')[domEl.getAttribute('statusable-id').length- 1];
  sd_meta_datum_id = $(domEl).attr('data-sd_meta_datum_id')
  status = $(domEl).hasClass('draft')
  paramKey = "section_flag_#{sectionId}"
  url_base = $('.sd-form')[0].action
  $.post "#{url_base}/section_update", { sd_meta_datum: "#{paramKey}": status }, (data) ->
    check sectionId, data.status
    return
  return

$(document).on 'click', '.status-switch', ->
  if this.id[0] != 5
    if not (StatusChecker.check_status() || $(this).hasClass( 'completed' ))
      $('#status-check-modal').foundation("open");
    else
      updateSectionFlag this
  return

$(document).on 'click', '#abort-status-switch', ->
  StatusChecker.highlight_empty()
  $('#status-check-modal').foundation("close");

$(document).on 'click', '#confirm-status-switch', ->
  updateSectionFlag $( '.status-switch' )[0]
  $('#status-check-modal').foundation("close");

check = (panelNumber, status) ->
  `var check`
  if status == true or status == 'true'
    $('#'.concat(panelNumber.toString(), '-yes-no-section.status-switch')).removeClass 'draft warning'
    $('#'.concat(panelNumber.toString(), '-yes-no-section.status-switch')).addClass 'completed'
    $('#'.concat(panelNumber.toString(), '-yes-no-section.status-switch')).html 'Completed'
  else
    $('#'.concat(panelNumber.toString(), '-yes-no-section.status-switch')).removeClass 'completed warning'
    $('#'.concat(panelNumber.toString(), '-yes-no-section.status-switch')).addClass 'draft'
    $('#'.concat(panelNumber.toString(), '-yes-no-section.status-switch')).html 'Draft'
  check = ' <i class="fa fa-check"></i>'
  link = $("#panel-#{panelNumber}-label")
  check_container = $(".check-container[panel-number='#{panelNumber}']")
  check_container.html ''
  if status == true or status == 'true'
    check_container.html check
    link.css 'color': 'green'
  else
    link.css 'color': 'unset'
  return

initializeSwitches = ->
  for elem in $( '.to-be-checked' )
    check $( elem ).find( '.check-container' ).attr('panel-number'), true
    $( elem ).removeClass( 'to-be-checked' )
  return

document.addEventListener 'turbolinks:load', ->
  do ->
    return if $('body.sd_meta_data').length == 0

    initializeSwitches()
    bind_srdr20_saving_mechanism()
    apply_all_select2()

  return  # END document.addEventListener 'turbolinks:load', ->
