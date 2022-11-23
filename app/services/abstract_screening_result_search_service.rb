class AbstractScreeningResultSearchService
  def initialize(abstract_screening, query, page, per_page, order)
    @abstract_screening = abstract_screening
    @query = query
    @page = page
    @per_page = per_page
    @order = order
  end

  def elastic_search
    if @query == '*'
      AbstractScreeningResult
        .search(
          body: {
            "query": { "bool":
              {
                "must": {
                  "match_all": {}
                },
                "filter": [{ "term": { "abstract_screening_id": { "value": @abstract_screening.id } } }]
              } },
            "sort": @order,
            "from": @per_page * (@page - 1),
            "size": @per_page
          }
        )
    else
      AbstractScreeningResult
        .search(
          body: {
            "query": {
              "bool": {
                "must": {
                  "bool": {
                    "should": [
                      {
                        "dis_max": {
                          "queries": [
                            {
                              "multi_match": {
                                "query": @query,
                                "boost": 10,
                                "operator": 'and',
                                "analyzer": 'searchkick_search',
                                "fields": [
                                  '*.analyzed'
                                ],
                                "type": 'best_fields'
                              }
                            },
                            {
                              "multi_match": {
                                "query": @query,
                                "boost": 10,
                                "operator": 'and',
                                "analyzer": 'searchkick_search2',
                                "fields": [
                                  '*.analyzed'
                                ],
                                "type": 'best_fields'
                              }
                            },
                            {
                              "multi_match": {
                                "query": @query,
                                "boost": 1,
                                "operator": 'and',
                                "analyzer": 'searchkick_search',
                                "fuzziness": 1,
                                "prefix_length": 0,
                                "max_expansions": 3,
                                "fuzzy_transpositions": true,
                                "fields": [
                                  '*.analyzed'
                                ],
                                "type": 'best_fields'
                              }
                            },
                            {
                              "multi_match": {
                                "query": @query,
                                "boost": 1,
                                "operator": 'and',
                                "analyzer": 'searchkick_search2',
                                "fuzziness": 1,
                                "prefix_length": 0,
                                "max_expansions": 3,
                                "fuzzy_transpositions": true,
                                "fields": [
                                  '*.analyzed'
                                ],
                                "type": 'best_fields'
                              }
                            }
                          ]
                        }
                      }
                    ]
                  }
                },
                "filter": [
                  {
                    "term": {
                      "abstract_screening_id": {
                        "value": @abstract_screening.id
                      }
                    }
                  }
                ]
              }
            },
            "sort": @order,
            "from": @per_page * (@page - 1),
            "size": @per_page
          }
        )
    end
  end
end
