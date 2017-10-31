class NewExtractionFormsProjectsSection extends React.Component {
  constructor(props, context) {
    super(props, context);

    this.handleClick = this.handleClick.bind(this);
  }

  handleClick() {
    if (typeof this.refs !== 'undefined') {
      var name = this.refs.name.value;

      console.log('The name value is ' + name + '.');
    } else {
      console.log('Oh ohh, this.refs is undefined. You probably forgot to bind handleClick to `this`.')
      console.log('In the constructor do this:')
      console.log('this.handleClick = this.handleClick.bind(this)');
      console.log(this);
    }
  }

  render() {
    return (
      <div>

        <input ref='name' placeholder='Enter the name of the new section' />
        <button onClick={ this.handleClick }>Submit</button>

      </div>
    )
  }
}
