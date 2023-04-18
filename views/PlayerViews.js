import React from 'react';

const exports = {};

// Player views must be extended.
// It does not have its own Wrapper view.

exports.GetFinger = class extends React.Component {
  render() {
    const {parent, playable, finger} = this.props;
    return (
      <div>
        {finger ? 'It was a draw! Pick again.' : ''}
        <br />
        {!playable ? 'Please wait...' : ''}
        <b4 />
        <h1>Please enter the amount of your fingers</h1>
        <br />
        <button
          disabled={!playable}
          onClick={() => parent.playHand('0F')}
        >0F</button>
        <button
          disabled={!playable}
          onClick={() => parent.playHand('1F')}
        >1F</button>
        <button
          disabled={!playable}
          onClick={() => parent.playHand('2F')}
        >2F</button>
        <button
          disabled={!playable}
          onClick={() => parent.playHand('3F')}
        >3F</button>
                <button
          disabled={!playable}
          onClick={() => parent.playHand('4F')}
        >4F</button>
                <button
          disabled={!playable}
          onClick={() => parent.playHand('5F')}
        >5F</button>
      </div>
    );
  }
}

exports.GetGuess = class extends React.Component {
  render() {
    const {parent, playable, finger} = this.props;
    return (
      <div>
        <h1>Please enter your guess</h1>
        <br />
        {!playable ? 'Please wait...' : ''}
        <br />
        <button
          disabled={!playable}
          onClick={() => parent.playGuess('0F')}
        >0F</button>
        <button
          disabled={!playable}
          onClick={() => parent.playGuess('1F')}
        >1F</button>
        <button
          disabled={!playable}
          onClick={() => parent.playGuess('2F')}
        >2F</button>
        <button
          disabled={!playable}
          onClick={() => parent.playGuess('3F')}
        >3F</button>
                <button
          disabled={!playable}
          onClick={() => parent.playGuess('4F')}
        >4F</button>
        <button
          disabled={!playable}
          onClick={() => parent.playGuess('5F')}
        >5F</button>
        <button
          disabled={!playable}
          onClick={() => parent.playGuess('6F')}
        >6F</button>
        <button
          disabled={!playable}
          onClick={() => parent.playGuess('7F')}
        >7F</button>
        <button
          disabled={!playable}
          onClick={() => parent.playGuess('8F')}
        >8F</button>
        <button
          disabled={!playable}
          onClick={() => parent.playGuess('9F')}
        >9F</button>
        <button
          disabled={!playable}
          onClick={() => parent.playGuess('10F')}
        >10F</button>
      </div>
    );
  }
}

exports.WaitingForResults = class extends React.Component {
  render() {
    return (
      <div>
        Waiting for results...
      </div>
    );
  }
}

exports.Done = class extends React.Component {
  render() {
    const {outcome} = this.props;
    return (
      <div>
        Thank you for playing. The outcome of this game was:
        <br />{outcome || 'Unknown'}
      </div>
    );
  }
}

exports.Timeout = class extends React.Component {
  render() {
    return (
      <div>
        There's been a timeout. (Someone took too long.)
      </div>
    );
  }
}

export default exports;