//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require datatables
//= require init

//= require jquery.turbolinks
//= require datatables
//= require foundation
//= require toastr_rails
//= require cocoon
//= require jquery_mark_es6
//= require list.min.js
//= require jquery.form.min.js
//= require sortable-rails-jquery
//= require activestorage
//= require foundation-datepicker.min

// require assignments
// require author
// require cable
// require citations
// require extraction_forms_projects
// require extraction_forms_projects_sections
// require extraction_forms_projects_sections_type1s
// require extractions
// require extractions_extraction_forms_projects_sections_question_row_column_fields
// require extractions_extraction_forms_projects_sections_type1_row_columns
// require extractions_extraction_forms_projects_sections_type1_rows
// require extractions_extraction_forms_projects_sections_type1s
// require forms
// require invitations
// require journal
// require key_questions
// require keywords
// require labels
// require organizations
// require profiles
// require project_report_links
// require projects
// require projects_users_roles
// require questions
// require records
// require result_statistic_sections
// require screening_options
// require sd_key_questions
// require sd_meta_data
// require sd_picods_types
// require sd_search_databases
// require searches
// require static_pages
// require tasks
// require teams

//= require dropzone

//= require_tree .

//$(function(){ $( document ).foundation(); });

'use strict';

var delay;

// Adds a delay function for all to use.
//
// Call like: delay( thingToDelay( optionalParams ), timeInMs )
delay = (function() {
  var timer;
  timer = 0;
  return function(callback, ms) {
    clearTimeout(timer);
    timer = setTimeout(callback, ms);
  };
})();

// Source: https://hackernoon.com/copying-text-to-clipboard-with-javascript-df4d4988697f
const copyToClipboard = str => {
  const el = document.createElement('textarea');  // Create a <textarea> element
  el.value = str;                                 // Set its value to the string that you want copied
  el.setAttribute('readonly', '');                // Make it readonly to be tamper-proof
  el.style.position = 'absolute';
  el.style.left = '-9999px';                      // Move outside the screen to make it invisible
  document.body.appendChild(el);                  // Append the <textarea> element to the HTML document
  const selected =
    document.getSelection().rangeCount > 0        // Check if there is any content selected previously
      ? document.getSelection().getRangeAt(0)     // Store selection if found
      : false;                                    // Mark as false to know no selection existed before
  el.select();                                    // Select the <textarea> content
  document.execCommand('copy');                   // Copy - only works as a result of a user action (e.g. click events)
  document.body.removeChild(el);                  // Remove the <textarea> element
  if (selected) {                                 // If a selection existed before copying
    document.getSelection().removeAllRanges();    // Unselect everything on the HTML document
    document.getSelection().addRange(selected);   // Restore the original selection
  }
};

const copyToClipboardMessage = ( e ) => {
  e.preventDefault();
  copyToClipboard( $( e.target ).text() );
  $( e.target ).append( '<span class="copied-message" style="color: green; font-size: 0.8em;"> Copied!</span>' );
  $( '.copied-message' ).delay( 800 ).fadeOut( 400 ).queue( function() { $( this ).remove(); } );

  return false;
};

// Set toastr.js options.
toastr.options = {
  'closeButton': false,
  'showMethod': 'slideDown',
  'hideMethod': 'slideUp',
  'closeMethod': 'slideUp',
  'hideDuration': '10',
  'closeDuration': '10',
  'timeOut': '1200',
  'extendedTimeOut': '4000'
};

Dropzone.autoDiscover = false;

/// GLOBAL function TO SEND ASYNC FORMS  
function send_async_form(form) {
  var formData = new FormData(form);

  $.ajax({
    type: "PATCH",
    url: form.action,
    data: formData,
    async: true,
    contentType: false,
    processData: false
  })
}

// Global function to check if a string is a URL
function get_valid_URL(string){
  try {
    return new URL(string).href
  } catch (_) {
    return false;
  }
}

document.addEventListener( 'turbolinks:load', function() {
  $( document ).foundation();

  // Check for dirty forms.
  window.onbeforeunload = function (e) {
    if ( $( '.dirty' ).length !== 0 ) {
      var message = 'Potential loss of unsaved data.',
      e = e || window.event;
      // For IE and Firefox
      if (e) {
        e.returnValue = message;
      }

      // For Safari
      return message;
    }
    return;
  };

//  $( '#options' )
//    .on('cocoon:before-insert', function(e,task_to_be_added) {
//      task_to_be_added.fadeIn('slow');
//    })
//    .on('cocoon:after-insert', function(e, added_task) {
//      // e.g. set the background of inserted task
//      added_task.css("background","red");
//    })
//    .on('cocoon:before-remove', function(e, task) {
//      // allow some time for the animation to complete
//      $(this).data('remove-timeout', 1000);
//      task.fadeOut('slow');
//    });

  for (let orderable_list of Array.from($( '.orderable-list' ))) {
    //# CHANGE THIS
    const ajax_url = $( '.orderable-list' ).attr( 'orderable-url' );
    let saved_state = null;

    //# helper method for converting class name into camel case
    const camel2snake =  s  =>
      s.replace( /(?:^|\.?)([A-Z])/g, ( x, y ) => `_${y.toLowerCase()}`).replace(/^_/, '')
    ;

    //# send updated positions to the server
    const send_positions = function( ) {
      let positions = [];
      for (let element of Array.from($( orderable_list ).find( '.orderable-item' ))) {
        positions.push( $( element ).attr( 'position' ) );
      }
      positions = positions.sort();
      //class_name = camel2snake $( '.orderable-item' ).first().attr( 'orderable-type' )
      let idx = 0;
      let params = { orderings: [ ] };
      for (let element of Array.from($( orderable_list ).find( '.orderable-item' ))) {
        const ordering_id = $( element ).attr( 'ordering-id' );
        // how do we make this part generic
        params.orderings.push({ id: ordering_id, position: positions[ idx ] });
        idx++;
      }

      // save current state
      $.ajax({
        type: 'PATCH',
        url: ajax_url,
        dataType: 'script',
        data: params,
        success( data ) {
            // if successful, update positions
            let idx = 0;
            for (let element of Array.from($( orderable_list ).find( '.orderable-item' ))) {
              $( element ).attr( 'position', positions[ idx ] );
              idx++;
            }
            // then save state
            saved_state = $( orderable_list ).sortable( "toArray" );

            return toastr.success( 'Positions successfully updated' );
          },
        error( data ) {
            $( orderable_list ).sortable( 'sort', saved_state );

            return toastr.error( 'ERROR: Cannot save new position' );
          }
      });
    };

    //# update handler for sortable list
    const on_update =  e  => send_positions( );

    //# save state when dragging starts
    const on_start =  e  => saved_state = $( orderable_list ).sortable( 'toArray' );

    $( orderable_list ).sortable({ onUpdate: on_update, onStart: on_start });
    saved_state = $( orderable_list ).sortable( 'toArray' );
  }

  $( "select.select2" ).select2();
  $( "select.select2_multi" ).select2({
    multiple: 'true'
  });

  ////################################################
  // State Toggler for EEFPS
  if ( $( 'body.extractions.work' ).length > 0 ) {
    $( '.status-switch' ).on( 'click', function () {
      var $outer_form = $( this ).parents( 'form' )
      var $outer_input = $outer_form.find( 'select' )
      var draft_id = $outer_form.find( 'option' ).filter(function () { return $(this).html() == "Draft"; }).val()
      var completed_id = $outer_form.find( 'option' ).filter(function () { return $(this).html() == "Completed"; }).val()

      if ( $( this ).hasClass( 'completed' ) ) {
        $outer_input.val( draft_id ).change()
      } else if( $( this ).hasClass( 'draft' ) ) {
        $outer_input.val( completed_id ).change()
      }

      $( this ).removeClass( 'completed draft' )
      $( this ).addClass( 'waiting' )
      //$( this ).html( 'Waiting...' )

      $outer_form.submit()
    })
  }

} );
