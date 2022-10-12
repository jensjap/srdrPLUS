class CitationsProjectSearchService
  def initialize(project, query, page, per_page, order)
    @project = project
    @query = query
    @page = page
    @per_page = per_page
    @order = order
  end

  def elastic_search
    if @query == '*'
      CitationsProject
        .search(
          body: {
            "query": { "bool":
              {
                "must": {
                  "match_all": {}
                },
                "filter": [{ "term": { "project_id": { "value": @project.id } } }]
              } },
            "sort": @order,
            "from": @per_page * (@page - 1),
            "size": @per_page
          }
        )
    else
      CitationsProject
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
                      "project_id": {
                        "value": @project.id
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