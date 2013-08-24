# IS Framework [![BUILD STATUS](https://secure.travis-ci.org/sabinmarcu/IS.png)](http://travis-ci.org/sabinmarcu/IS) 
The pourpose of this framework is to make object handling and mixins much more easier to work with in CoffeeScript / JavaScript

The whole application is wrapped in a Node.JS application that handles specs, browser testing, compiling with Stitch, and a few others.

## Documentation
If you want to see the documentation, you can head over to [GitHub's pages](http://sabinmarcu.github.com/IS) and look through. You can try and connect the code to the documentation, after all, it's generated from the source code itself

## The Node.JS application
Has a command.js wrapper, so it is very easy to use.

	coffee boot
	coffee boot -s localhost -p 9323
	coffee boot -c ../project/src/IS.js
	coffee boot -c ../project/src/IS.js -w 0.5

And so forth.

The first one sets up an http server on preset variables that compiles the project and feeds the `application.js` for you to handle in the console window of the browser (browser testing)

The second one sets up a server on `localhost:9323`, just like the previous one (except different variables)

The third one compiles the framework to the file hinted in the argument.

The forth one adds a watch (basically, a timer function), so that every `0.5 seconds` it compiles the code to the path specified.

## The framework 

# @TODO
