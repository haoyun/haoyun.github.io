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


### License

* zurb/foundation-sites is licensed under the [MIT License][MIT].
* Hakyll is licensed under the [BSD-3-Clause License][BSD-3]

* Contents of blog posts (`src_site/n/posts/**`) are licensed under the
  [Creative Commons Attribution 4.0 International License][CC-BY],
  unless otherwise stated.
* All the other contents are licensed under the [MIT License],


[CC-BY]: //creativecommons.org/licenses/by/4.0/
[BSD-3]: //hackage.haskell.org/package/hakyll-4.12.1.0/src/LICENSE
[MIT]: //github.com/zurb/foundation-sites/blob/develop/LICENSE

[Hakyll]: //jaspervdj.be/hakyll/tutorials/01-installation.html
[Foundation]: //foundation.zurb.com/sites/docs/installation.html#install-with-foundation-cli