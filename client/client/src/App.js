import './App.css';
import {React, Component} from 'react';

class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      value: 'Transaction Id',
      id: 'The address of the contract',
      subId: 'Please denote the corporate Id',
    };

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) {
    this.state[event.target.name] = event.target.value;
  }
  
  
  insertTx = async (txId, recv_addr, txAmount) => {
    console.log("this ran");
    const url_tx = encodeURIComponent(txId);
    const url_recv = encodeURIComponent(recv_addr);
    const url_subId = encodeURIComponent(txAmount);

    return await fetch(`http://localhost:5000/write?txId=${url_tx}&recAddr=${url_recv}&txAmount=${url_subId}`, {method :'POST'})
      .then(response => {
        console.log(response.json);
        return response.json;
      });
    
    // return await fetch('http://127.0.0.1:5000/write' + new URLSearchParams({
    //   txId: 42,
    //   recAddr: 20000,
    //   txAmount: 3
    // }), {
    //   method: 'POST'
    // }).then(response => {
    //   console.log(response.json)
    //   return response.json;
    // });

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
