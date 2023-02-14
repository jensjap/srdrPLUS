document.addEventListener 'DOMContentLoaded', ->
  do ->
    tableKey = window.location.pathname

    $('#citations-table').DataTable({
      "columnDefs": [{ "orderable": false, "targets": [4, 5] }],
      "lengthMenu": [[50, 100, 500, -1], [50, 100, 500, "All"]],
      "pagingType": "full_numbers",
      "stateSave": true,
      "stateDuration": 0,
      "stateSaveCallback": (settings, data) ->
        localStorage.setItem('DataTables-' + tableKey, JSON.stringify(data))
      "stateLoadCallback": (settings) ->
        return JSON.parse(localStorage.getItem('DataTables-'+ tableKey))
    })

######### CITATION MANAGEMENT
    ##### CHECK WHICH CONTROLLER ACTION THIS PAGE CORRESPONDS TO
    ##### ONLY RUN THIS CODE IF WE ARE IN INDEX CITATIONS PAGE
    if $( 'body.citations.index' ).length == 0
      return

    $( '#delete-citations-select-all' ).change ( e )->
      e.preventDefault()
      if $( this ).prop('checked')
        $( '#delete-citations-inner input[type="checkbox"]' ).prop( 'checked', true )
      else
        $( '#delete-citations-inner input[type="checkbox"]' ).prop( 'checked', false )

    $( '#delete-citations-inner input[type="checkbox"]' ).change ( e )->
        e.preventDefault()
        if $( this ).prop('checked')
          if not $( '#delete-citations-inner input[type="checkbox"]:not(:checked)' ).length > 0
            $( '#delete-citations-select-all' ).prop( 'checked', true )
        else
          e.preventDefault()
          $( '#delete-citations-select-all' ).prop( 'checked', false )

    #### FILE DROPZONE
    Dropzone.options.fileDropzone = {
      url: $('#fileDropzone').attr('dropzone-path'),
      autoProcessQueue: true,
      uploadMultiple: false,

      init: ()->
        wrapperThis = this
        this.on('sending', (file, xhr, formData) ->
          ris_type_id = $( "#dropzone-div input#ris-file-type-id" ).val()
          csv_type_id = $( "#dropzone-div input#csv-file-type-id" ).val()
          endnote_type_id = $( "#dropzone-div input#endnote-file-type-id" ).val()
          pubmed_type_id = $( "#dropzone-div input#pubmed-file-type-id" ).val()
          json_type_id = $( "#dropzone-div input#json-file-type-id" ).val()

          file_extension = file.name.split('.').pop()
          switch
            when file_extension == 'ris'
              file_type_id = ris_type_id
              file_type_name = "RIS File"
            when file_extension == 'csv'
              file_type_id = csv_type_id
              file_type_name = "Comma Separated File"
            when file_extension == 'enw'
              file_type_id = endnote_type_id
              file_type_name = "EndNote File"
            when file_extension == 'json'
              file_type_id = json_type_id
              file_type_name = "JSON File"
            else
              file_type_id = pubmed_type_id
              file_type_name = "PubMed ID List"

          if not confirm("This looks like a " + file_type_name + ". Do you wish to continue?")
            wrapperThis.removeFile(file);

          formData.append("authenticity_token", $("#dropzone-div input[name='authenticity_token']").val())
          formData.append("projects_user_id", $("#dropzone-div").find("#import_projects_user_id").val())
          formData.append("import_type_id", $("#dropzone-div").find("#import_import_type_id").val())
          formData.append("file_type_id", file_type_id)
          formData.append("authenticity_token", $("#dropzone-div input[name='authenticity_token']").val())
        )

        this.on('success', (file, response) ->
          toastr.success('Citation file successfully uploaded. You will be notified by email when citaion import finishes.')
          wrapperThis.removeFile(file)
        )
        this.on('error', (file, error_message) ->
          toastr.error("ERROR: Cannot upload citation file. #{ error_message }")
          wrapperThis.removeFile(file)
        )
    }

    new Dropzone( '#fileDropzone' )


    list_options = { valueNames: [ 'citation-numbers', 'citation-title', 'citation-authors', 'citation-journal', 'citation-journal-date', 'citation-abstract', 'citation-abstract' ] }

    ## Method to pull citation info from PUBMED as XML
    fetch_from_pubmed = ( pmid ) ->
      $.ajax 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi',
        type: 'GET'
        dataType: 'xml'
        data: { db : 'pubmed', retmode: 'xml', id : pmid }
        error: ( jqXHR, textStatus, errorThrown ) ->
          console.log errorThrown
          toastr.error( 'Could not fetch citation info from PUBMED' )
        success: ( data, textStatus, jqXHR ) ->
          return 0 unless ( $(data).find('ArticleTitle').text()? )
          name = $(data).find('ArticleTitle').text() || ''

          abstract = ''
          for node in $(data).find('AbstractText')
            abstract += $(node).text()
            abstract += "\n"

          authors = [ ]
          for node in $(data).find('Author')
            first_name = $(node).find('ForeName').text() || $(node).find('Initials').text() || ''
            last_name = $(node).find('LastName').text() || ''
            author_name = last_name + ' ' + first_name
            if author_name == ' '
              author_name = $(node).find('CollectiveName').text() || ''
            if author_name != ''
              authors.push( author_name )

          keywords = [ ]
          for node in $(data).find('Keyword')
            keyword = $(node).text() || ''
            keywords.push( keyword )

          journal = {  }
          journal[ 'name' ] = $(data).find('Journal').find( 'Title' ).text() || ''
          journal[ 'issue' ] = $(data).find('JournalIssue').find( 'Issue' ).text() || ''
          journal[ 'vol' ] = $(data).find('JournalIssue').find( 'Volume' ).text() || ''
          ## My philosophy is to use publication year whenever possible, as researchers seem to be most concerned about the year, and it is easier to parse and sort - Birol

          dateNode = $(data).find('JournalIssue').find( 'PubDate' )

          if $( dateNode ).find( 'Year' ).length > 0
            journal[ 'year' ] = $( dateNode ).find( 'Year' ).text()
          else if $( dateNode ).find( 'MedlineDate' ).length > 0
            journal[ 'year' ] = $( dateNode ).find( 'MedlineDate' ).text()
          else
            journal[ 'year' ] = ''

          citation_hash = {
            pmid: pmid,
            name: name,
            abstract: abstract,
            keywords: keywords,
            journal: journal,
            authors: authors.join(', ')
          }
          populate_citation_fields citation_hash

    populate_citation_fields = ( citation ) ->
      $( '.citation-fields' ).find( '.citation-name input' ).val citation[ 'name' ]
      $( '.citation-fields' ).find( '.citation-authors textarea' ).val citation[ 'authors' ]
      $( '.citation-fields' ).find( '.citation-abstract textarea' ).val citation[ 'abstract' ]
      $( '.citation-fields' ).find( '.journal-name input' ).val citation[ 'journal' ][ 'name' ]
      $( '.citation-fields' ).find( '.journal-volume input' ).val citation[ 'journal' ][ 'vol' ]
      $( '.citation-fields' ).find( '.journal-issue input' ).val citation[ 'journal' ][ 'issue' ]
      $( '.citation-fields' ).find( '.journal-year input' ).val citation[ 'journal' ][ 'year' ]
      $( '.citation-fields' ).find( '.project_citations_pmid input' ).val citation[ 'pmid' ]

      for keyword in citation[ 'keywords' ]
        keywordselect = $('.KEYWORDS select')
        $.ajax(
          type: 'GET'
          data: { q: keyword }
          url: '/api/v1/keywords.json' ).then ( data ) ->
            # create the option and append to Select2
            option = new Option( data[ 'results' ][ 0 ][ 'text' ], data[ 'results' ][ 0 ][ 'id' ], true, true )
            keywordselect.append(option).trigger 'change'
            # manually trigger the `select2:select` event
            keywordselect.trigger
              type: 'select2:select'
              params: data: data[ 'results' ][ 0 ]
            return

      return

    ##### LISTENERS
    if not $( '#citations').attr( 'listeners-exist' )
      ## handler for selecting input type
      $( '#import-select' ).on 'change', () ->
        $( '#import-ris-div' ).hide()
        $( '#import-csv-div' ).hide()
        $( '#import-pubmed-div' ).hide()
        $( '#import-endnote-div' ).hide()
        switch $( this ).val()
          when 'ris' then $( '#import-ris-div' ).show()
          when 'csv' then $( '#import-csv-div' ).show()
          when 'pmid-list' then $( '#import-pubmed-div' ).show()
          when 'endnote' then $( '#import-endnote-div' ).show()

      # display upload button only if a file is selected
      $( 'input.file' ).on 'change', () ->
        if !!$( this ).val()
          $( this ).closest( '.simple_form' ).find( '.form-actions' ).show()
        else
          $( this ).closest( '.simple_form' ).find( '.form-actions' ).hide()

      # cocoon listeners
      # Note: some of the animations don't work well together and are disabled for now
      $( '#cp-insertion-node' ).on 'cocoon:before-insert', ( e, citation ) ->
        if not $( citation ).hasClass( 'authors-citation' )
          $( '.cancel-button' ).click()
        #citation.slideDown('slow')
      $( '#citations' ).find( '.list' ).on 'cocoon:after-remove', ( e, citation ) ->
        $( '#citations-form' ).submit()
      #$( '#cp-insertion-node' ).on 'cocoon:before-remove', ( e, citation ) ->
        #$(this).data('remove-timeout', 1000)
        #citation.slideUp('slow')
      $( document ).on 'cocoon:after-insert', ( e, insertedItem ) ->
       # $( insertedItem ).find( '.AUTHORS select' ).select2
       #   minimumInputLength: 0
       #   #closeOnSelect: false
       #   ajax:
       #     url: '/api/v1/authors.json'
       #     dataType: 'json'
       #     delay: 100
       #     data: (params) ->
       #       q: params.term
       #       page: params.page || 1
        $( insertedItem ).find( '.KEYWORDS select' ).select2
          minimumInputLength: 0
          #closeOnSelect: false
          ajax:
            url: '/api/v1/keywords.json'
            dataType: 'json'
            delay: 100
            data: (params) ->
              q: params.term
              page: params.page || 1

        $( insertedItem ).find( '#is-pmid' ).on 'click', () ->
          ## clean up the citation fields
          $( insertedItem ).find('.KEYWORDS select').val(null).trigger('change')
          $( insertedItem ).find('.citation-name input').val(null)
          $( insertedItem ).find('.citation-abstract textarea').val(null)
          $( insertedItem ).find('.journal-name input').val(null)
          $( insertedItem ).find('.journal-volume input').val(null)
          $( insertedItem ).find('.journal-issue input').val(null)
          $( insertedItem ).find('.journal-year input').val(null)

          ## fetch citations using value in "Accession Number"
          fetch_from_pubmed $( '.project_citations_accession_number input' ).val()

        $( insertedItem ).find( '.citation-select' ).select2
          minimumInputLength: 0
          ajax:
            url: '/api/v1/citations/titles.json',
            dataType: 'json'
            delay: 100
            data: (params) ->
              q: params.term
              page: params.page || 1

        # submit form when "Save Citation" button is clicked
        $( insertedItem ).find( '.save-citation' ).on 'click', () ->
          $( '#citations-form' ).submit()
          $('.cancel-button').click()

      $( '#citations' ).attr( 'listeners-exist', 'true' )
