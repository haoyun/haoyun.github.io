#/bin/zsh

set -Eeuxo pipefail                         # Safer bash scripts
                                            # https://goo.gl/u9Djx4

                                            
chcp 65001                                  # Ensure to use UTF8
git checkout source                         # Ensure to be in the source branch


                                            # check if any untracted files
                                            # https://goo.gl/w6KqrP
UNTRACTED=$(git ls-files --others --exclude-standard)
if [[ ! -z "${UNTRACTED// }" ]]; then
    print "
**************************************************
     _ 
    | |
    | |
    |_|    Please check untracted files first!
     _ 
    (_)

**************************************************"
    exit 1                                  # if any, exit with code 1.
else
    print "
    There is no untracted files.
    All modified files will be commited.
"
fi                                          # then manually add or ignore files

git commit -a -m 'source update'            # commit changes
git push -u origin source                   # push to remote origin/source
SHA=$(git log -1 HEAD --pretty=format:%h)   # get the comit hash


cd Foundation/                              # Build Foundation Styles
# npm install
# bower install                             # if not installed
foundation build > /dev/null 2>&1


cd ../                                      # rebuild the site
cabal run rebuild > /dev/null 2>&1          # clean and build


mkdir html_public                           # temp folder to hold generated site
rsync -ar _site/ html_public/               # cp files into html_public


REMOTE="git@github.com:haoyun/haoyun.github.io.git"

cd html_public
git init                                    # initialize a new repo,
git remote add origin $REMOTE               # add remote
git add .                                   # commit generated site, and force
git commit -m 'site generated with '"$SHA" 
git push -f -u origin master                # push to remote origin/master

cd ..
rm html_public -rf                          # remote temp folder

git pull                                    # update
git gc                                      # do some cleaning
