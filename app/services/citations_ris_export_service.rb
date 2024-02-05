require 'erb'

class CitationsRisExportService < CitationsExportService
    private

    def export_payload_in_ris(citations)
        payload = []
        payload << " "
        citations.each do |cit|
            authors = cit[:author_string].split(',')
            s = ERB.new(<<-BLOCK).result(binding)
TY  - JOUR
T1  - <%= cit[:title] %>
<% authors.each do |author| %>AU  - <%= author.strip %>
<% end %>DB  - SRDRPlus
C1  - Citation ID: <%= cit[:srdr_citation_id] %>
C2  - Refman ID: <%= cit[:refman] %>
C3  - Other Reference: <%= cit[:other_reference] %>
ID  - <%= cit[:srdr_citations_project_id] %>
AID  - PMID: <%= cit[:pmid] %>
AN  - <%= cit[:pmid] %>
AB  - <%= cit[:abstract] %>
SP  - <%= cit[:page_start] %>
EP  - <%= cit[:page_end] %>
DO  - <%= cit[:doi] %>
AN  - <%= cit[:accession_no] %>
JO  - <%= cit[:journal] %>
VO  - <%= cit[:volume] %>
IS  - <%= cit[:issue] %>
Y2  - <%= cit[:publication_date] %>
DA  - <%= cit[:updated_at] %>
ER  -
BLOCK
            payload << s
        end
        payload.join("\n")
    end
end
