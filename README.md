Grammophone
===========

This is a client-side web app for analyzing and transforming context-free grammars. It was developed with the support and guidance of [Robin Cockett](http://pages.cpsc.ucalgary.ca/~robin/) at the [University of Calgary](http://ucalgary.ca), and it's based on his [Context Free Grammar Checker](http://smlweb.cpsc.ucalgary.ca).


Building the app
----------------

Grammophone uses [Yarn](https://yarnpkg.com/) to handle its build system and development dependencies. [How to install Yarn](https://yarnpkg.com/en/docs/install).

First, install dependencies:

    yarn install

To rebuild JavaScript and CSS as files are changed:

    yarn run watch

To bundle the JavaScript and CSS and copy files to dist/ for distribution:

    yarn run dist

[Jison](http://zaach.github.com/jison/) is used to build the app's grammar specification parser, but the parser (src/grammar/parser.js) is checked into the repository. To generate the parser:

    yarn run generate-parser



### To quickly build it


To build it also on Windows, see: https://github.com/mdaines/grammophone/issues/3
```
yarn install &&
yarn run dist &&
yarn run generate-parser
```


Tests
-----

Currently only the routines in grammar/ have tests. (There are no controller or view tests yet.) To run these:

    yarn test
