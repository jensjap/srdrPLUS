class Caretkeeper
  @save_caret_position: () ->
    Caretkeeper.focused_elem_id = document.activeElement.id
    Caretkeeper.focused_elem_cursor_location = document.activeElement.selectionStart

  @restore_caret_position: () ->
    try
      $( "##{Caretkeeper.focused_elem_id}" ).focus()
      $( "##{Caretkeeper.focused_elem_id}" )[0].setSelectionRange(Caretkeeper.focused_elem_cursor_location, Caretkeeper.focused_elem_cursor_location)
    catch e
      console.log "Error: " + e

class Timekeeper
  @_timer_dict: {}

  @clear_timer_for_form: ( form ) ->
    formId = form.getAttribute( 'id' )
    if formId of @_timer_dict
      clearTimeout( @_timer_dict[formId] )

  @create_timer_for_form: ( form, duration ) ->
    Timekeeper.clear_timer_for_form( form )
    formId = form.getAttribute( 'id' )
    @_timer_dict[ formId ] = setTimeout ->
      validate_and_send_async_form( form )
    , duration
    @_timer_dict[ formId ]

class StatusChecker
  restore_highlights: false

  @save_highlights: ( ) ->
    if $( '.empty-input, .empty-associations, .empty-kq' ).length > 0
      StatusChecker.prototype.restore_highlights = true

  @restore_highlights: ( ) ->
    if StatusChecker.prototype.restore_highlights
      StatusChecker.highlight_empty()

  @input_empty: ( input ) ->
    if $( input ).is( 'input[type=file]' )
      if $( input ).closest( '.sd-inner' ).find( 'img' ).length
        return false
      else
        return true
    return !$( input ).val()

  @get_all_inputs: ( ) ->
    return $( 'input:not([type="hidden"], .select2-search__field), select, textarea' )

  @get_all_unmapped_srdr_kq: () ->
    return $('.srdr-key-questions-box').find( '.srdr-kq:not(".kq-mapped")' )

  @get_all_unmapped_report_kq: () ->
    return $('.report-key-questions-box').find( '.srdr-kq-target-prompt:not(".hide")' ).parents('.report-kq')

  @check_kq_mapping_status: ( ) ->
    if StatusChecker.get_all_unmapped_srdr_kq().length > 0
      return false
    if StatusChecker.get_all_unmapped_report_kq().length > 0
      return false
    return true

  @check_status: ( ) ->
    if $( '.zero-nested-associations' ).length > 0
      return false

    for elem in StatusChecker.get_all_inputs()
      if StatusChecker.input_empty( elem )
        return false
    return true

  @remove_highlights: ( ) ->
    StatusChecker.prototype.restore_highlights = false
    $( '.empty-associations' ).removeClass( 'empty-associations' )
    $( '.empty-input' ).removeClass( 'empty-input' )
    $( '.empty-kq' ).removeClass( 'empty-kq' )

  @highlight_input: ( input ) ->
    if $( input ).is( 'select' )
      $( input ).parent().find( '.select2-container' ).addClass( 'empty-input' )
    else
      $( input ).addClass( 'empty-input' )

  @highlight_empty: ( ) ->
    #kq-mapping
    StatusChecker.get_all_unmapped_srdr_kq().addClass( 'empty-kq' )
    StatusChecker.get_all_unmapped_report_kq().addClass( 'empty-kq' )
    #inputs
    for elem in StatusChecker.get_all_inputs()
      if StatusChecker.input_empty( elem )
        completeable = false
        StatusChecker.highlight_input( elem )
    #associations
    $( '.zero-nested-associations a' ).addClass( 'empty-associations' )

  @initialize_listeners: ( ) ->
    $( '#status-check-modal[data-reveal]' ).on 'closed.zf.reveal', ( e ) ->
      StatusChecker.remove_highlights()
    $( document ).keyup ( e ) ->
      if not $('#status-check-modal').is(':visible')
        return
      code = e.keyCode || e.which;
      if code in [13]
        $( '#confirm-status-switch' ).click()
        return
    $( document ).on 'click', '.status-switch', ->
      if this.id[0] != "5"
        if not (StatusChecker.check_status() || $(this).hasClass( 'completed' ))
          $('#status-check-modal').foundation("open")
        else
          updateSectionFlag this
      else
        if not (StatusChecker.check_kq_mapping_status() || $(this).hasClass( 'completed' ))
          $('#status-check-modal').foundation("open")
        else
          updateSectionFlag this

      return
    $( document ).on 'click', '#abort-status-switch', ->
      $('#status-check-modal').foundation("close");
      StatusChecker.highlight_empty()
    $( document ).on 'click', '#confirm-status-switch', ->
      StatusChecker.remove_highlights()
      updateSectionFlag $( '.status-switch' )[0]
      $('#status-check-modal').foundation("close");

class Collapser
  @_state_dict: {}
  @initialize_states: ( ) ->
    for elem in $( '.collapse-content' )
      Collapser._state_dict[$( elem ).data( 'result-item-id' )] = true
  @initialize_listeners: ( ) ->
    $( '.collapsed-icon' ).on 'click', ->
      $parent = $( $( this ).closest( '.nested-fields' ) )
      $parent.find( '.collapse-content' ).removeClass( 'hide' )
      $parent.find( '.not-collapsed-icon' ).removeClass( 'hide' )
      $parent.find( '.collapsed-icon' ).addClass( 'hide' )
      $( 'textarea' ).each () ->
        this.style.height = this.scrollHeight + "px"

      Collapser._state_dict[$parent.find( '.collapse-content' ).data('result-item-id')] = false
    $( '.not-collapsed-icon' ).on 'click', ->
      $parent = $( $( this ).closest( '.nested-fields' ) )
      $parent.find( '.collapse-content' ).addClass( 'hide' )
      $parent.find( '.not-collapsed-icon' ).addClass( 'hide' )
      $parent.find( '.collapsed-icon' ).removeClass( 'hide' )
      Collapser._state_dict[$parent.find( '.collapse-content' ).data('result-item-id')] = true
  @restore_states: ( ) ->
    for result_item_id,state of Collapser._state_dict
      if not state
        $parent = $( '.collapse-content[data-result-item-id="' + result_item_id + '"]' ).closest( '.nested-fields' )
        $parent.find( '.collapse-content' ).removeClass( 'hide' )
        $parent.find( '.not-collapsed-icon' ).removeClass( 'hide' )
        $parent.find( '.collapsed-icon' ).addClass( 'hide' )
        $( 'textarea' ).each () ->
          this.style.height = this.scrollHeight + "px"

class Select2Helper
  @copy_sd_outcome_names: ( ) ->
    sd_outcome_option_set = new Set()
    $( '.sd-outcome-select2 option' ).each ( i, option_elem ) ->
      if option_elem.text != ''
        sd_outcome_option_set.add( option_elem.text )
    $( '.sd-outcome-select2' ).each ( i, select2_elem ) ->
      sd_outcome_option_set.forEach ( key, option_text, sd_outcome_option_set ) ->
        if not $( select2_elem ).find("option[value='" + option_text + "']").length
          newOption = new Option( option_text, option_text, false, false)
          $( select2_elem ).append( newOption ).trigger( 'change.select2' )

validate_and_send_async_form = ( form ) ->
  if not validate_form_inputs( form )
    return
  $( '.preview-button' ).attr( 'disabled', '' )
  send_async_form( form )

restrictedCharacters =
  '<': '&lt;'
  '>': '&gt;'

escapeRestrictedCharacters = (string) ->
  String(string).replace /[<>]/g, (s) ->
    restrictedCharacters[s]

# Set the field to display from the result set.
formatResultSelection = ( result, container ) ->
  escapeRestrictedCharacters(result.text)

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
      if input_val.includes( ' ' )
        $input_elem.parents('div.input').addClass( 'invalid-url' )
        is_input_valid = false
      else
        valid_href = get_valid_URL( input_val )
        if not valid_href
          https_appended_val = "https://" + input_val
          valid_href = get_valid_URL( https_appended_val )
          if not valid_href
            $input_elem.parents('div.input').addClass( 'invalid-url' )
            is_input_valid = false
          else
            #$input_elem.val( valid_href )
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
    allowClear: true,
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
  init_select2(".key_question_type", '/key_question_types')
  init_select2(".sd_picods_type", '/sd_picods_types')
  init_select2(".review_type", '/review_types')
  init_select2(".data_analysis_level", '/data_analysis_levels')
  sd_meta_datum_id = $(".sd_picods_key_question").data('sd-meta-datum-id')
  init_select2(".sd_picods_key_question", "/sd_key_questions?sd_meta_datum_id=" + sd_meta_datum_id)
  $(".sd_picods_key_question").select2({ placeholder: "-- Select Key Question(s) --" })

  $( '.apply-select2' ).select2
    selectOnClose: true,
    allowClear: true,
    placeholder: '-- Select or type other value --'

  $( '.sd-outcome-select2' ).select2
    tags: true,
    allowClear: true,
    selectOnClose: true,
    placeholder: '-- Select or type other value --'

  $('.sd-select2, .apply-select2, .sd-outcome-select2').on 'select2:unselecting', ( e ) ->
    $(this).on 'select2:opening', ( event ) ->
      event.preventDefault()
  $('.sd-select2').on 'select2:unselect', ( e ) ->
    sel = $(this)
    setTimeout( () ->
      sel.off('select2:opening');
    , 100)

  Select2Helper.copy_sd_outcome_names()

add_form_listeners =( form ) ->
  $form = $( form )
  # Use this to keep track of the different timers.
  formId = $form.attr( 'id' )

  $form.find( 'select, input[type="file"], input.fdp' ).on 'change', ( e ) ->
    e.preventDefault()
    # Mark form as 'dirty'.
    $form.addClass( 'dirty' )
    Timekeeper.create_timer_for_form $form[0], 750

  $form.on 'cocoon:after-insert cocoon:after-remove', ( e ) ->
    # Mark form as 'dirty'.
    $form.addClass( 'dirty' )
    Timekeeper.create_timer_for_form $form[0], 750

  $( "a.remove-figure[data-remote]" ).on "ajax:success",  ( event ) ->
    $( this ).parent().closest( 'div' ).fadeOut();

  $form.find('input[type="text"], textarea').on 'paste', ( e ) ->
    $form.addClass( 'dirty' )
    Timekeeper.create_timer_for_form $form[0], 750

  # Text Field.
  $form.find('input[type="text"], textarea').keyup ( e ) ->
#    if !!$(e.target).val()
#      StatusChecker.remove_highlights()
    e.preventDefault()

    # Ignore 'keyup' for a list of keys.
    code = e.keyCode || e.which;
    # 9: tab; 16: shift; 500: left-arrow; 38: up-arrow; 39: right-arrow; 40: down-arrow; 18: option; 91: cmd
    if code in [9, 16, 18, 37, 38, 39, 40, 91]
      return

    # Mark form as 'dirty'.
    $form.addClass( 'dirty' )
    Timekeeper.create_timer_for_form $form[0], 750

bind_srdr20_saving_mechanism = () ->
  $( 'form.sd-form' ).each ( i, form ) ->
    add_form_listeners( form )
    $cocoon_container = $( form ).parents( '.cocoon-container' )
    $cocoon_container.on 'sd:form-loaded', ( e ) ->
      add_form_listeners( $cocoon_container.children( 'form' ) )
      Collapser.initialize_listeners()
      Collapser.restore_states()
      apply_all_select2()
      $( 'textarea' ).each () ->
        this.style.height = this.scrollHeight + "px"
      Select2Helper.copy_sd_outcome_names()
      $( '.reveal' ).foundation()
  $( '.infoDiv' ).first().on 'sd:replaced-html-content', ( e ) ->
    Caretkeeper.restore_caret_position()
    StatusChecker.restore_highlights()
  $( '.infoDiv' ).first().on 'sd:replacing-html-content', ( e ) ->
    Caretkeeper.save_caret_position()
    StatusChecker.save_highlights()

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

check = (panelNumber, status) ->
  `var check`
  if status == true or status == 'true'
    $('#'.concat(panelNumber.toString(), '-yes-no-section.status-switch')).removeClass 'draft warning'
    $('#'.concat(panelNumber.toString(), '-yes-no-section.status-switch')).addClass 'completed'
    $('#'.concat(panelNumber.toString(), '-yes-no-section.status-switch span.status-label')).html 'Completed'
    if panelNumber == '3'
      $('.mapping-kq-title').removeClass('hide')
  else
    $('#'.concat(panelNumber.toString(), '-yes-no-section.status-switch')).removeClass 'completed warning'
    $('#'.concat(panelNumber.toString(), '-yes-no-section.status-switch')).addClass 'draft'
    $('#'.concat(panelNumber.toString(), '-yes-no-section.status-switch span.status-label')).html 'Draft'
    if panelNumber == '3'
      $('.mapping-kq-title').addClass('hide')

  check = ' <i class="fa fa-check"></i>'
  link = $("#panel-#{panelNumber}-label")
  check_container = $(".check-container[panel-number='#{panelNumber}']")
  check_container.html ''
  if status == true or status == 'true'
    check_container.html check
    link.css 'color': 'green'
  else
    link.css 'color': 'unset'

  # this is a bad way to do this, but the idea is I now have to compute completion percentage on the go
  $( '.progress-meter' ).attr( 'style', 'width: ' + ($('i.fa.fa-check').length * 100.0/ 9.0).toString() + '%' );
  return

initializeSwitches = ->
  for elem in $( '.to-be-checked' )
    check $( elem ).find( '.check-container' ).attr('panel-number'), true
    $( elem ).removeClass( 'to-be-checked' )
  return

document.addEventListener 'DOMContentLoaded', ->
  do ->
    return if $('body.sd_meta_data.edit').length == 0
    StatusChecker.initialize_listeners()
    Collapser.initialize_states()
    Collapser.initialize_listeners()
    initializeSwitches()
    bind_srdr20_saving_mechanism()
    setTimeout (->
      apply_all_select2()
    ), 50
    $( 'textarea' ).each () ->
      this.style.height = this.scrollHeight + "px"
