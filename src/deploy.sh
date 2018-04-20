#/bin/zsh



chcp 65001

# Build CSS
cd Foundation/ &&
foundation build &&

# Build site
cd ../
cabal run rebuild &&

# Check are there any untracted files,
# IF there is, exit,
#     use git add, or gitignore manually
#     The problem is that not all new files are useful
# Otherwise, continue
UNTRACTED=$(git ls-files --others --exclude-standard)
if [[ -z "${UNTRACTED// }" ]]; then
    print "
**************************************************
     _ 
    | |
    | |
    |_|    Please check untracted files first!
     _ 
    (_)
    
**************************************************"
fi

git clean -xf &&  # Sometimes this is dangerous but it is also useful
git commit -m -a 'source update'
SHA=$(git log -1 HEAD --pretty=format:%h)
rsync -avr --delete --exclude='.git' _site/ html_public/
cd html_public
git add .
# git commit -m 'pages update'    # use the next if you do not want to keep
git commit --amend -m "generated from $SHA"  # any history of generated pages   
git push origin HEAD:master -f
cd ..
git add .
git commit -m 'update submodule'
git push origin source &&
cd Foundation/ &&
foundation build &&
cd ../
