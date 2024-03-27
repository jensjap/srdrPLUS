(function() {
  document.addEventListener('DOMContentLoaded', function() {
    return (function() {
      var fetch_from_pubmed, id_counter, list_options, populate_citation_fields, tableKey;
      id_counter = -1;
      tableKey = window.location.pathname;
      $('#citations-table').DataTable({
        ajax: "/projects/" + ($('#citations-table').data('project_id')) + "/citations",
        processing: true,
        serverSide: true,
        "columns": [
          {
            "data": "accession_number_alts"
          }, {
            "data": "refman"
          }, {
            render: function(data, type, row, meta) {
              return '<div style="overflow: hidden; height: 18px;" title="' + row['authors'] + '">' + row['authors_short'] + '</div>';
            }
          }, {
            render: function(data, type, row, meta) {
              return '<div style="overflow: hidden; height: 18px;">' + row['name'] + '</div>';
            }
          }, {
            render: function(data, type, row, meta) {
              if ($('#project_consolidator').data('project-consolidator') !== true) {
                return '';
              }
              return '<a href="/citations/' + row['citation_id'] + '/edit?project_id=' + row['project_id'] + '">Edit</a>';
            }
          }, {
            render: function(data, type, row, meta) {
              if ($('#project_leader').data('project-leader') !== true) {
                return '';
              }
              id_counter += 1;
              return '<input name="project[citations_projects_attributes][' + id_counter + '][_destroy]" type="hidden" value="0" autocomplete="off"> <input id="sf_cp-' + row['citation_id'] + '" type="checkbox" value="1" name="project[citations_projects_attributes][' + id_counter + '][_destroy]"> <input autocomplete="off" type="hidden" value="' + row['citations_project_id'] + '" name="project[citations_projects_attributes][' + id_counter + '][id]" id="project_citations_projects_attributes_' + id_counter + '_id">';
            }
          }
        ],
        "columnDefs": [
          {
            "orderable": false,
            "targets": [4, 5]
          }
        ],
        "": "",
        "pagingType": "full_numbers",
        "paging": true,
        "stateSave": true,
        "stateSaveParams": function(settings, data) {
          return data.search.search = "";
        },
        "stateDuration": 0,
        "stateSaveCallback": function(settings, data) {
          var obj;
          return fetch('/profile/storage', {
            method: "POST",
            headers: {
              Accept: "application/json",
              "Content-Type": "application/json",
              "X-Requested-With": "XMLHttpRequest",
              "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
            },
            body: JSON.stringify({
              storage: (
                obj = {},
                obj["DataTables-" + tableKey] = data,
                obj
              )
            })
          });
        },
        "stateLoadCallback": function(settings, cb) {
          fetch('/profile/storage').then(function(response) {
            return response.json().then(function(data) {
              return cb(data["DataTables-" + tableKey]);
            });
          });
          return void 0;
        }
      });
      if ($('body.citations.index').length === 0) {
        return;
      }
      $('#delete-citations-select-all').change(function(e) {
        e.preventDefault();
        if ($(this).prop('checked')) {
          return $('#delete-citations-inner input[type="checkbox"]').prop('checked', true);
        } else {
          return $('#delete-citations-inner input[type="checkbox"]').prop('checked', false);
        }
      });
      $('#delete-citations-inner input[type="checkbox"]').change(function(e) {
        e.preventDefault();
        if ($(this).prop('checked')) {
          if (!$('#delete-citations-inner input[type="checkbox"]:not(:checked)').length > 0) {
            return $('#delete-citations-select-all').prop('checked', true);
          }
        } else {
          e.preventDefault();
          return $('#delete-citations-select-all').prop('checked', false);
        }
      });
      Dropzone.options.fileDropzone = {
        url: $('#fileDropzone').attr('dropzone-path'),
        autoProcessQueue: false,
        uploadMultiple: false,
        init: function() {
          var wrapperThis;
          wrapperThis = this;
          this.on('addedfile', function(file) {
            var csv_type_id, endnote_type_id, file_extension, file_type_id, file_type_name, json_type_id, modalDecisionPromise, pubmed_type_id, ris_type_id, showModalEvent;
            ris_type_id = $("#dropzone-div input#ris-file-type-id").val();
            csv_type_id = $("#dropzone-div input#csv-file-type-id").val();
            endnote_type_id = $("#dropzone-div input#endnote-file-type-id").val();
            pubmed_type_id = $("#dropzone-div input#pubmed-file-type-id").val();
            json_type_id = $("#dropzone-div input#json-file-type-id").val();
            file_extension = file.name.split('.').pop().toLowerCase();
            switch (false) {
              case file_extension !== 'ris':
                file_type_id = ris_type_id;
                file_type_name = "RIS File";
                break;
              case file_extension !== 'csv':
                file_type_id = csv_type_id;
                file_type_name = "Comma Separated File";
                break;
              case file_extension !== 'enw':
                file_type_id = endnote_type_id;
                file_type_name = "EndNote File";
                break;
              case file_extension !== 'json':
                file_type_id = json_type_id;
                file_type_name = "JSON File";
                break;
              case file_extension !== 'txt':
                file_type_id = pubmed_type_id;
                file_type_name = "PubMed ID List";
                break;
              default:
                toastr.error("ERROR: Unknown file extension. Unable to process.");
                wrapperThis.removeFile(file);
                return;
            }
            file.file_type_id = file_type_id;
            showModalEvent = new CustomEvent('show-modal', {
              detail: "This looks like a " + file_type_name + ". Do you wish to continue?"
            });
            window.dispatchEvent(showModalEvent);
            modalDecisionPromise = new Promise(function(resolve, reject) {
              return window.modalResolve = resolve;
            });
            return modalDecisionPromise.then(function(confirmed) {
              if (confirmed) {
                return wrapperThis.processQueue();
              } else {
                return wrapperThis.removeFile(file);
              }
            });
          });
          this.on('sending', function(file, xhr, formData) {
            var file_type_id;
            file_type_id = file.file_type_id;
            formData.append("authenticity_token", $("#dropzone-div input[name='authenticity_token']").val());
            formData.append("projects_user_id", $("#dropzone-div").find("#import_projects_user_id").val());
            formData.append("import_type_id", $("#dropzone-div").find("#import_import_type_id").val());
            formData.append("file_type_id", file_type_id);
            return formData.append("authenticity_token", $("#dropzone-div input[name='authenticity_token']").val());
          });
          this.on('success', function(file, response) {
            wrapperThis.removeFile(file);
            return window.location.href = '/imports/' + response.id;
          });
          return this.on('error', function(file, error_message) {
            toastr.error("ERROR: Cannot upload citation file. " + error_message);
            return wrapperThis.removeFile(file);
          });
        }
      };
      new Dropzone('#fileDropzone');
      list_options = {
        valueNames: ['citation-numbers', 'citation-title', 'citation-authors', 'citation-journal', 'citation-journal-date', 'citation-abstract', 'citation-abstract']
      };
      fetch_from_pubmed = function(pmid, insertedItem) {
        return $.ajax('https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi', {
          type: 'GET',
          dataType: 'xml',
          data: {
            db: 'pubmed',
            retmode: 'xml',
            id: pmid
          },
          error: function(jqXHR, textStatus, errorThrown) {
            console.log(errorThrown);
            return toastr.error('Could not fetch citation info from PUBMED');
          },
          success: function(data, textStatus, jqXHR) {
            var abstract, author_name, authors, citation_hash, dateNode, first_name, i, j, journal, k, keyword, keywords, last_name, len, len1, len2, name, node, ref, ref1, ref2;
            if (!($(data).find('ArticleTitle').text() != null)) {
              return 0;
            }
            name = $(data).find('ArticleTitle').text() || '';
            abstract = '';
            ref = $(data).find('AbstractText');
            for (i = 0, len = ref.length; i < len; i++) {
              node = ref[i];
              abstract += $(node).text();
              abstract += "\n";
            }
            authors = [];
            ref1 = $(data).find('Author');
            for (j = 0, len1 = ref1.length; j < len1; j++) {
              node = ref1[j];
              first_name = $(node).find('ForeName').text() || $(node).find('Initials').text() || '';
              last_name = $(node).find('LastName').text() || '';
              author_name = last_name + ' ' + first_name;
              if (author_name === ' ') {
                author_name = $(node).find('CollectiveName').text() || '';
              }
              if (author_name !== '') {
                authors.push(author_name);
              }
            }
            keywords = [];
            ref2 = $(data).find('Keyword');
            for (k = 0, len2 = ref2.length; k < len2; k++) {
              node = ref2[k];
              keyword = $(node).text() || '';
              keywords.push(keyword);
            }
            journal = {};
            journal['name'] = $(data).find('Journal').find('Title').text() || '';
            journal['issue'] = $(data).find('JournalIssue').find('Issue').text() || '';
            journal['vol'] = $(data).find('JournalIssue').find('Volume').text() || '';
            dateNode = $(data).find('JournalIssue').find('PubDate');
            if ($(dateNode).find('Year').length > 0) {
              journal['year'] = $(dateNode).find('Year').text();
            } else if ($(dateNode).find('MedlineDate').length > 0) {
              journal['year'] = $(dateNode).find('MedlineDate').text();
            } else {
              journal['year'] = '';
            }
            citation_hash = {
              pmid: pmid,
              name: name,
              abstract: abstract,
              keywords: keywords,
              journal: journal,
              authors: authors.join(', ')
            };
            return populate_citation_fields(citation_hash, insertedItem);
          }
        });
      };
      populate_citation_fields = function(citation, insertedItem) {
        var i, keyword, keywordselect, len, ref;
        $(insertedItem).find('.citation-name input').val(citation['name']);
        $(insertedItem).find('.citation-authors textarea').val(citation['authors']);
        $(insertedItem).find('.citation-abstract textarea').val(citation['abstract']);
        $(insertedItem).find('.journal-name input').val(citation['journal']['name']);
        $(insertedItem).find('.journal-volume input').val(citation['journal']['vol']);
        $(insertedItem).find('.journal-issue input').val(citation['journal']['issue']);
        $(insertedItem).find('.journal-year input').val(citation['journal']['year']);
        $(insertedItem).find('input.input-citation-pmid').val(citation['pmid']);
        ref = citation['keywords'];
        for (i = 0, len = ref.length; i < len; i++) {
          keyword = ref[i];
          keywordselect = $('.KEYWORDS select');
          $.ajax({
            type: 'GET',
            data: {
              q: keyword
            },
            url: '/api/v1/keywords.json'
          }).then(function(data) {
            var option;
            option = new Option(data['results'][0]['text'], data['results'][0]['id'], true, true);
            keywordselect.append(option).trigger('change');
            keywordselect.trigger({
              type: 'select2:select',
              params: {
                data: data['results'][0]
              }
            });
          });
        }
      };
      if (!$('#citations').attr('listeners-exist')) {
        $('#import-select').on('change', function() {
          $('#import-ris-div').hide();
          $('#import-csv-div').hide();
          $('#import-pubmed-div').hide();
          $('#import-endnote-div').hide();
          switch ($(this).val()) {
            case 'ris':
              return $('#import-ris-div').show();
            case 'csv':
              return $('#import-csv-div').show();
            case 'pmid-list':
              return $('#import-pubmed-div').show();
            case 'endnote':
              return $('#import-endnote-div').show();
          }
        });
        $('input.file').on('change', function() {
          if (!!$(this).val()) {
            return $(this).closest('.simple_form').find('.form-actions').show();
          } else {
            return $(this).closest('.simple_form').find('.form-actions').hide();
          }
        });
        $('#cp-insertion-node').on('cocoon:before-insert', function(e, citation) {
          if (!$(citation).hasClass('authors-citation')) {
            return $('.cancel-button').click();
          }
        });
        $('#citations').find('.list').on('cocoon:after-remove', function(e, citation) {
          return $('#citations-form').submit();
        });
        $(document).on('cocoon:after-insert', function(e, insertedItem) {
          $(insertedItem).find('.KEYWORDS select').select2({
            minimumInputLength: 0,
            ajax: {
              url: '/api/v1/keywords.json',
              dataType: 'json',
              delay: 100,
              data: function(params) {
                return {
                  q: params.term,
                  page: params.page || 1
                };
              }
            }
          });
          $(insertedItem).find('.is-pmid').on('click', function() {
            var pmid_lookup_value;
            $(insertedItem).find('.KEYWORDS select').val(null).trigger('change');
            $(insertedItem).find('.citation-name input').val(null);
            $(insertedItem).find('.citation-abstract textarea').val(null);
            $(insertedItem).find('.journal-name input').val(null);
            $(insertedItem).find('.journal-volume input').val(null);
            $(insertedItem).find('.journal-issue input').val(null);
            $(insertedItem).find('.journal-year input').val(null);
            pmid_lookup_value = $(insertedItem).find('input.accession-number-lookup-field').val();
            return fetch_from_pubmed(pmid_lookup_value, insertedItem);
          });
          $(insertedItem).find('.citation-select').select2({
            minimumInputLength: 0,
            ajax: {
              url: '/api/v1/citations/titles.json',
              dataType: 'json',
              delay: 100,
              data: function(params) {
                return {
                  q: params.term,
                  page: params.page || 1
                };
              }
            }
          });
          return $(insertedItem).find('.save-citation').on('click', function() {
            $('#citations-form').submit();
            return $('.cancel-button').click();
          });
        });
        return $('#citations').attr('listeners-exist', 'true');
      }
    })();
  });

}).call(this);
