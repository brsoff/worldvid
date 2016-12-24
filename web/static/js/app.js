// Phoenix' dependencies
import '../../../deps/phoenix/priv/static/phoenix'
import '../../../deps/phoenix_html/priv/static/phoenix_html'

// Shiny new, hot React component
import React from 'react';
import { render } from 'react-dom';

function Root() {
  return <h1>Hi</h1>;
}

render(<Root />, document.getElementById('root'))
