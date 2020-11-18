//= require jquery
//= require jquery_ujs
//= require datatables
//= require init

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
//= require tether.min
//= require dropzone
//= require ahrq_foresee_qa_survey

//= require_tree .

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

// Attach NIH autocomplete for UCUM (Unified Code for Units of Measure) to any input field with class 'ucum'.
$( document ).on( 'cocoon:after-insert', function(e, insertedItem, originalEvent) {
  $( '.ucum' ).each(function() {
    new Def.Autocompleter.Search(this, 'https://clinicaltables.nlm.nih.gov/api/ucum/v3/search', { tableFormat: true, valueCols: [0], colHeaders: ['Code', 'Name'] });
  });
});

// Wait for DOM ready:
document.addEventListener('DOMContentLoaded', function() {
  $('#loading-indicator').hide()
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

  // Attach NIH autocomplete for UCUM (Unified Code for Units of Measure) to any input field with class 'ucum'.
  $( '.ucum' ).each(function() {
    new Def.Autocompleter.Search(this, 'https://clinicaltables.nlm.nih.gov/api/ucum/v3/search', { tableFormat: true, valueCols: [0], colHeaders: ['Code', 'Name'] });
  });

  function initialize_orderable_element( scope ) {
    for (let orderable_list of Array.from( $( scope ).find( '.orderable-list' ))) {
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
              toastr.success( 'Positions successfully updated' );
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

      $(orderable_list).sortable({ onUpdate: on_update, onStart: on_start });

      if ($('.sort-handle').length > 0) {
        $(orderable_list).sortable( "option", "handle", ".sort-handle" );
      }

      saved_state = $( orderable_list ).sortable( 'toArray' );
    }
  }

  initialize_orderable_element( document );
  $( document ).on( 'srdr:content-loaded', function( e ) {
    initialize_orderable_element( e.target );
  } );

  ////################################################
  // State Toggler for EEFPS
  if ( $( 'body.extractions.work' ).length > 0 ) {
    $( 'body' ).on( 'click', '.status-switch', function () {
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
