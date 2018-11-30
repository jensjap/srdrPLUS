// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require foundation
//= require turbolinks
//= require toastr_rails
//= require select2
//= require cocoon
//= require jquery_mark_es6
//= require react
//= require react_ujs
//= require components
//= require list.min.js
//= require jquery.form.min.js
//= require sortable-rails-jquery
//= require_tree .

//$(function(){ $(document).foundation(); });

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


// Set toastr.js options.
toastr.options = {
  'closeButton': false,
  'showMethod': 'slideDown',
  'hideMethod': 'slideUp',
  'closeMethod': 'slideUp',
  'positionClass': 'toast-bottom-right',
  'closeDuration': 400,
  'timeOut': 10000,
  'extendedTimeOut': 10000,
};

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
    const ajax_url = "http://0.0.0.0:3000/api/v1/orderings/update_positions";
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
} );
