import './App.css';
import {React, Component} from 'react';

class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      value: 'Please include the url to the receipt',
      id: 'Please include the persons Id',
      subId: 'Please denote the corporate Id',
    };

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) {
    this.state[event.target.name] = event.target.value;
  }
  
  insertTx = async (link, id, subId) => {
    console.log("this ran");
    return await fetch('http:127.0.0.1/write' + new URLSearchParams({
      link: 'value',
      id: 2,
      subId: 3
    })).then(response => {
      console.log(response.json)
      return response.json;
    });

  }

  handleSubmit(event) {
    console.log(event.currentTarget.contains);
    console.log("id: " + this.state.id);
    console.log("sub_id: " + this.state.subId);
    console.log("value: " + this.state.value);
    this.insertTx(this.state.value, this.state.id, this.state.subId)
    .then(response => {
      console.log(response);
      alert("successfully synced to blockchain");
    })
  }

  render() {
    return (
      <form onSubmit={this.handleSubmit}>
        <label>
          
          <textarea placeholder={this.state.value} onChange={this.handleChange} name='value'/>
          <textarea placeholder={this.state.id}  onChange={this.handleChange} name='id'/>
          <textarea placeholder={this.state.subId} onChange={this.handleChange} name='subId'/>
        </label>
        <input type="submit" value="Submit" />
      </form>
    );
  }
}
export default App;
