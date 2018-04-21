Source code for <https://haoyun.github.io>
==========================================

This is the source code for my homepage
[Natural Stupidity](https://haoyun.github.io).
The site is built with Hakyll (for generating the static site) and
Zurb Foundation (for stylesheets).

If you would like to build it, following the following steps.

#### Requirements

* [Hakyll][]
* [Zurb Foundation for Sites][Foundation]


#### Build the site

```bash
git clone git@github.com:haoyun/haoyun.github.io.git site
cd site
git checkout source
cd site/Foundation
bower install && npm install
foundation build
cd ..
cabal build
cabal run build
```

For more, see `/src/deploy.sh`.

[Hakyll]: //jaspervdj.be/hakyll/tutorials/01-installation.html
[Foundation]: //foundation.zurb.com/sites/docs/installation.html#install-with-foundation-cli