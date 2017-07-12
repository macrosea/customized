#######
##   This file is used to define some public function 
#
#
throw()
{
  err_no=$1
  echo $2
  exit $err_no
}

#############################
#  def some function about bash env
#  in this section, D_PUB D_PRIV should be defined before called
#  D_PUB means some bash env is independed on the OS
#  D_PIV means some bash env is depended on the OS
handle_bashrc()
{
    echo "handle bashrc ..."
    test -f ~/.bashrc || touch ~/.bashrc
    [ $(grep -c bash_aliases ~/.bashrc) -eq 0 ] && echo "test -f ~/.bash_aliases && source ~/.bash_aliases" >> ~/.bashrc
}

handle_alias()
{
    [  ! -d "$D_PRIV" ] && throw 250  "not define the context!!!Exit!!!"
    [  ! -d "$D_PUB" ] && throw 250 "not define the context!!!Exit!!!"
    echo "handle bash aliases..."
    fn=bash_aliases
    f_priv=$D_PRIV/$fn
    f_pub=$D_PUB/$fn
    test -f ~/.$fn || touch ~/.$fn
    key="#import-priv-alias"
    str="test -f $f_priv && source $f_priv $key"
    [ $(grep -c "$key" ~/.$fn) -eq 0 ] && echo "$str" >> ~/.$fn
    key="#import-pub-alias"
    str="test -f $f_pub && source $f_pub $key"
    [ $(grep -c "$key" ~/.$fn) -eq 0 ] && echo "$str" >> ~/.$fn
}

handle_profile()
{
    [  ! -d "$D_PRIV" ] && throw 250  "not define the context!!!Exit!!!"
    [  ! -d "$D_PUB" ] && throw 250 "not define the context!!!Exit!!!"
    echo "handle bash profile..."
    fn=bash_profile
    f_priv="$D_PRIV/$fn"
    f_pub="$D_PUB/$fn"
    test -f ~/.$fn || touch ~/.$fn
    key="#import-priv-profile"
    str="test -f $f_priv && source $f_priv $key"
    [ $(grep -c "$key" ~/.$fn) -eq 0 ] && echo "$str" >> ~/.$fn
    key="#import-pub-profile"
    str="test -f $f_pub && source $f_pub $key"
    [ $(grep -c "$key" ~/.$fn) -eq 0 ] && echo "$str" >> ~/.$fn

    #[ $(uname -s) == "Darwin" ] && return 0

    read -p "screen or tmux? : " sel
    case "$sel" in
        "tmux"   )  env_=tmux;;
        "screen" )  env_=screen;;
        * )         env_="screen";  echo "screen will be used" ;;
    esac

    f_env="$D_PUB/$env_/$fn"
    key="#import-env-profile"
    str="test -f $f_env && source $f_env $key"
    [ $(grep -c "$key" ~/.$fn) -eq 0 ] && echo "$str" >> ~/.$fn
}

link_apps()
{
    local dir=$1
    # link bin/* 
    for f in $dir/bin/*; do
        if [ -f $f ]; then
            rm -f /usr/local/bin/$(basename $f)
            ln -s $f /usr/local/bin/$(basename $f)
            echo "$(basename $f) has been link to /usr/local/bin"
        fi
    done
    #link sbin/*
    for f in $dir/sbin/*; do
        if [ -f $f ]; then
            rm -f /usr/local/sbin/$(basename $f)
            ln -s $f /usr/local/sbin/$(basename $f)
            echo "$(basename $f) has been link to /usr/local/sbin"
        fi
    done
}

#############################
insapp()
{
  which $1 2>&1 > /dev/null && return 0
  [ $# -ne 1 ] && throw 255 "parameter error" 
  INSTALL=""
  which yum 2>&1 > /dev/null && INSTALL="yum install -y " 
  which apt-get 2>&1 > /dev/null && INSTALL="sudo apt-get install -y "
  [ "X$INSTALL" == "X" ] && throw 255 "which os ??"
  APP=$1
  $INSTALL $1
}

dl_and_install()
{
    local URL=$1
    local PKG=${URL##*/}
    local D_TMP=/tmp/somefiles
    local D_EXTRACT=$D_TMP/extract 
    local D_PWD=$(pwd)
    mkdir -p $D_TMP
    mkdir -p $D_EXTRACT
    wget -P $D_TMP $URL
    if [ ! -f $D_TMP/$PKG ]; then
        throw 11 "no file:$PKG"     
    fi    

    OPT=
    EXT=${PKG##*.}
    NAME_PKG=${PKG%.tar.$EXT}
    case "$EXT" in
      gz)  OPT="-zxf" ;;
      bz2) OPT="-jxf" ;;
      *) throw 12 "unsupported package" ;;
    esac 
    tar $OPT $D_TMP/$PKG -C $D_EXTRACT
    ls $D_EXTRACT/$NAME_PKG
    cd $D_EXTRACT/$NAME_PKG 
    if [ -f $D_EXTRACT/$NAME_PKG/configure ]; then
        $D_EXTRACT/$NAME_PKG/configure
    fi
    make && sudo make install
    cd $D_PWD
    rm -rf $D_TMP
}

#############################

