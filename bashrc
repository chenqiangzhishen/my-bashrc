# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

# Git branch in prompt.
function parse_git_dirty {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working directory clean" ]] && echo "*"
}

function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1$(parse_git_dirty)]/"
}

export PS1="\u@\h \W\[\e[32m\]\$(parse_git_branch)\[\e[0m\]$ "

alias git-tree='git log --graph --decorate --pretty=oneline --abbrev-commit'

function findme() {
  if [ -z $1 ]; then
      echo "Need one keyword you want to search"
  else
      grep -r -n "$1" * --color=auto
  fi
}

# dockertag base/hyperkube [prod|sit]
function dockertag(){
  if [ "x$2" = "x" -o "$2" = "prod" ] ; then
     registry_url=http://10.213.42.254:10500
  elif [ "$2" = "sit" ]; then
     registry_url=http://docker-registry.intra.sit.ffan.com:10500
  fi
  curl $registry_url/v2/$1/tags/list | python -mjson.tool
}

# dockerrepo [prod|sit]
function dockerrepo(){
  if [ "x$1" = "x" -o "$1" = "prod" ] ; then
     registry_url=http://10.213.42.254:10500
  elif [ "$1" = "sit" ]; then
     registry_url=http://docker-registry.intra.sit.ffan.com:10500
  fi
  curl $registry_url/v2/_catalog?n=3000 | python -mjson.tool
}

function docker-search(){
#!/bin/sh
#
# Simple script that will display docker repository tags.
#
# Usage:
#   $ docker-show-repo-tags.sh ubuntu centos
for Repo in $* ; do
  curl -s -S "https://registry.hub.docker.com/v2/repositories/library/$Repo/tags/" | \
    sed -e 's/,/,\n/g' -e 's/\[/\[\n/g' | \
    grep '"name"' | \
    awk -F\" '{print $4;}' | \
    sort -fu | \
    sed -e "s/^/${Repo}:/"
done
}
