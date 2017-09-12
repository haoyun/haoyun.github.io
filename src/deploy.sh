#/bin/zsh

chcp 65001
cd Foundation/ &&
foundation build &&
cd ../
cabal run rebuild &&
git clean -xf &&
rsync -avr --delete --exclude='.git' _site/ html_public/
cd html_public
git add .
# git commit -m 'pages update'    # use the next if you do not want to keep
git commit --amend --no-edit  # any history of generated pages   
git push origin HEAD:master -f
cd ..
git add .
git commit -m 'source update'
git push origin source &&
cd Foundation/ &&
foundation build &&
cd ../
