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
//= require levenshtein.min.js
//= require draggable/draggable.bundle.js
//= require xlsx.mini.js
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
  'timeOut': '0',
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

function autoResize(el) {
  $(el).height(el.scrollHeight);
}

// Attach NIH autocomplete for UCUM (Unified Code for Units of Measure) to any input field with class 'ucum'.
$( document ).on( 'cocoon:after-insert', function(e, insertedItem, originalEvent) {
  $( '.ucum' ).each(function() {
    new Def.Autocompleter.Search(this, 'https://clinicaltables.nlm.nih.gov/api/ucum/v3/search', { tableFormat: true, valueCols: [0], colHeaders: ['Code', 'Name'] });
  });
});

// Wait for DOM ready:
document.addEventListener('DOMContentLoaded', function() {
  // Initialize foundation for navbar and any non-section foundation JS
  $(document).foundation();
  $('#loading-indicator').hide();

  if ($( '.extractions.work' ).length > 0) return
  documentCode();
})

document.addEventListener('extractionSectionLoaded', function() {
  documentCode();
})

let documentCode = function() {
  // Initialize foundation again to apply foundation JS within the sections
  Foundation.reflow($('.ajax-section'));

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
    new Def.Autocompleter.Search(
      this,
      'https://clinicaltables.nlm.nih.gov/api/ucum/v3/search',
      { tableFormat: true, valueCols: [0], colHeaders: ['Code', 'Name'] }
    );
  });

  //#######################################################################################
  // Attaching SortableJS to .orderable-list (some orderable-items are <li> and some <tr>).
  const attachOrderable = ( orderable ) => {
    const ajax_url = $( orderable ).attr( 'orderable-url' );
    let savedState = null;

    // Send current order to server and save.
    const sendPositions = ( orderable, dropConflictingDependencies=false, lsofOrderingsToRemoveDependencies=[] ) => {
      let positions = [];
      let params = {
        drop_conflicting_dependencies: dropConflictingDependencies,
        lsof_orderings_to_remove_dependencies: lsofOrderingsToRemoveDependencies,
        orderings: []
      };

      const elements = Array.from( $( orderable ).find( '.orderable-item' ) );

      for ( let i=0; i < elements.length; i++ ) {
        params.orderings.push( { id: $( elements[i] ).attr( 'ordering-id' ), position: ( i ) } )
      }

      $.ajax({
        type: 'PATCH',
        url: ajax_url,
        dataType: 'script',
        data: params,
        success( data ) {
          // if successful, update positions
          let idx = 0;
          for ( let element of Array.from( $( orderable ).find( '.orderable-item' ) ) ) {
            $( element ).attr( 'position', positions[ idx ] );
            idx++;
          }
          // then save state
          savedState = $( orderable ).sortable( "toArray" );
          return toastr.success( 'Positions successfully updated' );
        },
        error( data ) {
          $( orderable ).sortable( 'sort', savedState );
          return toastr.error( 'ERROR: Cannot save new position due to a server error.');
        }
      });
    };

    const ensureValidOrder = ( e ) => {
      // Keep a running list of ordering ids that that questions are dependent on.
      let lsofDataDependentOrderingIds      = new Array();
      let lsofOrderingsToRemoveDependencies = new Array();
      let lsofOrderableItemsInReverse       = new Array();
      let validOrder = true  // Assume order is valid. Not all orderable things have dependencies.

      lsofOrderableItemsInReverse = $( e.item ).parent('.orderable-list').find( '.orderable-item' ).get().reverse()
      $( lsofOrderableItemsInReverse ).each( ( idx, el ) => {
        // Only run this code if orderable-item has potential dependencies.
        if (typeof $( el ).data( 'dependent' ) !== 'undefined') {
          for (let i=idx+1; i < lsofOrderableItemsInReverse.length; i++ ) {
            if ( $( lsofOrderableItemsInReverse[i] ).data( 'dependent' ).map( x => x.toString() ).includes( $( el ).attr( 'ordering-id' ) ) ) {
              validOrder = false;
              lsofOrderingsToRemoveDependencies.push( $( lsofOrderableItemsInReverse[i] ).attr( 'ordering-id' ) );
            }
          }
        }
      } );
      return {
        validOrder,
        lsofOrderingsToRemoveDependencies
      };
    };

    const sortSortableByListItemPosition = ( sortable ) => {
      let list = $( sortable[0].el );
      let listItems = list.find( 'tr' ).sort( function( a, b ) {
        return $( a ).attr( 'position' ) - $( b ).attr( 'position' );
      } );

      // List items can be <li> elements and sometimes they are <tr> elements
      // in tables.
      if ( listItems.length > 0 ) {
        list.find( 'tr' ).remove();
        list.append( listItems );
      } else {
        listItems = list.find( 'li' ).sort( function( a, b ) {
          return $( a ).attr( 'position' ) - $( b ).attr( 'position' );
        } );
        if ( listItems.length > 0 ) {
          list.find( 'li' ).remove();
          list.append( listItems );
        }
      }
      return false;
    };

    // Create Sortable object.
    let _sortable = new Sortable(orderable, {
      sort: true,
      onUpdate: ( e ) => {
        let overwrite_dependencies;
        let { validOrder, lsofOrderingsToRemoveDependencies } = ensureValidOrder( e );

        if ( validOrder == true ) {
          sendPositions( orderable, false );
        } else {
          overwrite_dependencies = confirm( 'The system detected a problem with dependencies due to re-ordering of the questions. Would you like to proceed regardless and have the system remove the conflicting dependencies for you?' )
          if ( overwrite_dependencies == true ) {
            sendPositions( orderable, true, lsofOrderingsToRemoveDependencies );
            toastr.warning( 'WARNING: You have chosen to re-order despite a dependency conflict. Conflicting dependencies have been automatically removed, please check the dependency structure.' );
          } else {
            toastr.warning( 'WARNING: Cannot save new positions. A dependency is preventing the new ordering from being saved. Please refresh the page to update the ordering. You may remove the conflicting dependencies manually to try again.' );
          }
        }
      },
      onStart: ( e ) => {
        savedState = $( e.item ).parent( '.orderable-list' ).sortable( 'toArray' );
      },
      store: {
        /**
         * Get the order of elements. Called once during initialization.
         * @param   {Sortable}  sortable
         * @returns {Array}
         */
        get: function (sortable) {
          var order = localStorage.getItem(sortable.options.group.name);
          return order ? order.split('|') : [];
        },

        /**
         * Save the order of elements. Called onEnd (when the item is dropped).
         * @param {Sortable}  sortable
         */
        set: function (sortable) {
          var order = sortable.toArray();
          localStorage.setItem(sortable.options.group.name, order.join('|'));
        }
      }
    } );

    sortSortableByListItemPosition( $( _sortable ) );
  };

  // Find all orderable-lists: create Sortable object and prepare for saving to server.
  $( '.orderable-list' ).each( ( idx, ol_el ) => {
    attachOrderable( ol_el );
  } );

  //// ################################################
  // Make sure window is in view when scrolling.
  document.addEventListener('drag', (event) => {
    let y = $(window).scrollTop();
    let eventY = event.clientY;

    if (eventY >= 10 && eventY < 50) {
      $(window).scrollTop(y - 10);
    } else if (eventY > window.innerHeight + window.scrollY - 200) {
      $(window).scrollTop(y + 10);
    }
  })

  ////################################################
  // State Toggler for EEFPS
  if ( $( 'body.extractions.work, body.extractions.comparison_tool, body.extractions.consolidate' ).length > 0 ) {
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

  $('textarea.resize-to-fit').each(function() {
    autoResize(this)
  })
}

function resizeIframe(iframe) {
  iframe.height = iframe.contentWindow.document.body.scrollHeight + "px";
}

addEventListener('resize', (event) => {
  var iframes = document.getElementsByClassName('iframe');
  for (var i = 0; i < iframes.length; ++i) {
    var item = iframes[i];  
    resizeIframe(item)
  }
});
