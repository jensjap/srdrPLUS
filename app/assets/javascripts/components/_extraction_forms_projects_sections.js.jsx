class ExtractionFormsProjectsSections extends React.Component {
  constructor(props, context) {
    super(props, context);

    this.state = {
      sections: [],
    };
  }

  componentDidMount() {
    console.log('Component mounted');
    console.log('Getting Sections');
    $.getJSON('/api/v1/extraction_forms_projects/1/extraction_forms_projects_sections.json', (response) => { this.setState({ sections: response }) });
    console.log('Done Getting Sections');
  }

  render() {
    var sections = this.state.sections.map((section) => {
      return (
        <div key={ section.id }>
          <h3>{ section.section.name }</h3>
        </div>
      )
    });

    return (
      <div>
        { sections }
      </div>
    )
  }
}
