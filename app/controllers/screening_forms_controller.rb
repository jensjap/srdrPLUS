class ScreeningFormsController < ApplicationController
  def index
    @project = Project.find(params[:project_id])

    respond_to do |format|
      format.json do
        @screening_form = ScreeningForm.find_or_create_by(project: @project, form_type: params[:form_type])
        render json: [
          { id: 1,
            name: 'Question 1',
            description: 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Nostrum eius ipsa quod. Culpa accusamus, commodi vero voluptates velit quam sunt laboriosam impedit, nisi est temporibus in sint natus quae aperiam!',
            rows: [{ id: 1, title: '1' }, { id: 2, title: '2' }, { id: 3, title: '3' }],
            columns: [{ id: 1, title: 'A' }, { id: 2, title: 'B' }, { id: 3, title: 'C' }],
            cells: [[{ id: 1, field_type: 'multi-select', options: [1, 2, 3, 4] },
                     { id: 2, field_type: 'multi-select', options: [1, 2, 3, 4] },
                     { id: 3, field_type: 'multi-select', options: [1, 2, 3, 4] }],
                    [{ id: 4, field_type: 'multi-select', options: [1, 2, 3, 4] },
                     { id: 5, field_type: 'multi-select', options: [1, 2, 3, 4] },
                     { id: 6, field_type: 'multi-select', options: [1, 2, 3, 4] }],
                    [{ id: 7, field_type: 'multi-select', options: [1, 2, 3, 4] },
                     { id: 8, field_type: 'multi-select', options: [1, 2, 3, 4] },
                     { id: 9, field_type: 'multi-select', options: [1, 2, 3, 4] }]] },
          { id: 2,
            name: 'Question 2',
            description: 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Nostrum eius ipsa quod. Culpa accusamus, commodi vero voluptates velit quam sunt laboriosam impedit, nisi est temporibus in sint natus quae aperiam!',
            rows: [{ id: 1, title: '1' }, { id: 2, title: '2' }, { id: 3, title: '3' }],
            columns: [{ id: 1, title: 'A' }, { id: 2, title: 'B' }, { id: 3, title: 'C' }],
            cells: [[{ id: 1, field_type: 'multi-select', options: [1, 2, 3, 4] },
                     { id: 2, field_type: 'multi-select', options: [1, 2, 3, 4] },
                     { id: 3, field_type: 'multi-select', options: [1, 2, 3, 4] }],
                    [{ id: 4, field_type: 'multi-select', options: [1, 2, 3, 4] },
                     { id: 5, field_type: 'multi-select', options: [1, 2, 3, 4] },
                     { id: 6, field_type: 'multi-select', options: [1, 2, 3, 4] }],
                    [{ id: 7, field_type: 'multi-select', options: [1, 2, 3, 4] },
                     { id: 8, field_type: 'multi-select', options: [1, 2, 3, 4] },
                     { id: 9, field_type: 'multi-select', options: [1, 2, 3, 4] }]] },
          { id: 3,
            name: 'Question 3',
            description: 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Nostrum eius ipsa quod. Culpa accusamus, commodi vero voluptates velit quam sunt laboriosam impedit, nisi est temporibus in sint natus quae aperiam!',
            rows: [{ id: 1, title: '1' }, { id: 2, title: '2' }, { id: 3, title: '3' }],
            columns: [{ id: 1, title: 'A' }, { id: 2, title: 'B' }, { id: 3, title: 'C' }],
            cells: [[{ id: 1, field_type: 'multi-select', options: [1, 2, 3, 4] },
                     { id: 2, field_type: 'multi-select', options: [1, 2, 3, 4] },
                     { id: 3, field_type: 'multi-select', options: [1, 2, 3, 4] }],
                    [{ id: 4, field_type: 'multi-select', options: [1, 2, 3, 4] },
                     { id: 5, field_type: 'multi-select', options: [1, 2, 3, 4] },
                     { id: 6, field_type: 'multi-select', options: [1, 2, 3, 4] }],
                    [{ id: 7, field_type: 'multi-select', options: [1, 2, 3, 4] },
                     { id: 8, field_type: 'multi-select', options: [1, 2, 3, 4] },
                     { id: 9, field_type: 'multi-select', options: [1, 2, 3, 4] }]] }
        ]
      end
      format.html
    end
  end
end
