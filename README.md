Hakyll Foundation Template
==========================

This is just a very basic template that you can use
* the [Hakyll][Hakyll] library, which is base on [Pandoc][Pandoc]
  to generate your static site, and
* the [Zurb Foundation][Foundation] framework to design your site.

## Requirements

* git
* rsync (Not really necessary but it will make life easier)
* GHC
  - Hakyll (4.9.*)
* NodeJS (Require by Foundation development, see more in `README.md` in the `Foundation` folder)

## Download ##

```bash
git clone --recursive git@github.com:haoyun/Hakyll-Foundation.git site
cd site
git checkout source
git submodule update --init --recursive
cd Foundation
npm install
bower install
```

## Develop ##

Run in `Foundation` folder
```bash
foundation watch
```

Run in `site` folder
```bash
cabal run watch
```

## Deploy ##

```bash
chcp 65001
cd Foundation
Foudation build &&
cd ..
cabal run rebuild &&
git clean -xf &&
rsync -avr --delete --exclude='.git' _site/ html_public/
cd html_public
git add .
git commit -m 'pages update'
git push orgin HEAD:master -f # without keeping any history of generated pages
cd ..
git add .
git commit -m 'source updae'
git push origin source
```


To-do List
----------

- [ ] Create multiple templates,
      each having a basic version and a ready-to-use version.
- [ ] Cover image field.
- [ ] Custimizable teaser.
- [ ] Run foundation watch and hakyll watch using one command.

[Hakyll]: https://jaspervdj.be/hakyll/
[Foundation]: http://foundation.zurb.com/
[Pandoc]: https://pandoc.org/

