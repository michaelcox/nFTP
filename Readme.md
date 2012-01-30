
# nFTP
      
An FTP client, written in [CoffeeScript](http://coffeescript.org/) for use with node.js.
  

## Usage
Functionality is currently in-progress.  To see a list of supported functionality, review the tests in the **test** folder.

     var ftp = new Ftp();

     ftp.connect(function(err) {
          // Do stuff
          ftp.disconnect(function() {
               // Disconnected
          });
     });


## Tests
Testing is done against a fake FTP server, also written in node.  Functionality of that server can be overwritten to satisfy edge cases.  The testing framework is [Mocha](http://visionmedia.github.com/mocha/) and [should.js](https://github.com/visionmedia/should.js).

To run the tests, first install test dependencies:

     cd test/
     npm install -d

Then you may run the tests with the included Makefile from the root of the project:

     make test

## License

(The MIT License)

Copyright (c) 2012 Michael Cox &lt;cox.michael@gmail.com&gt;

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.