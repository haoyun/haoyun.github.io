Hakyll Foundation Template
==========================

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

