#!/bin/bash

# Define error handling function
handle_error()
{
  echo "[`date +'%Y-%m-%d %H:%M:%S'`] ERROR: $1" >&2
  exit 1
}

# Configure mysql
if [ -d /etc/mysql ] ; then
  echo "[`date +'%Y-%m-%d %H:%M:%S'`] Configuring mysql..."
  MYSQL_CONF=/etc/mysql/my.cnf
  if [ -f /etc/mysql/mysql.cnf ] ; then
    # Alternative location
    MYSQL_CONF=/etc/mysql/mysql.cnf
  fi
  if [ -f /etc/mysql/conf.d/mysql.cnf ] ; then
    # Ubuntu before 16.04
    MYSQL_CONF=/etc/mysql/conf.d/mysql.cnf
  fi
  if [ -f /etc/mysql/mysql.conf.d/mysqld.cnf ] ; then
    # Ubuntu 16.04
    MYSQL_CONF=/etc/mysql/mysql.conf.d/mysqld.cnf
  fi
  echo "[`date +'%Y-%m-%d %H:%M:%S'`] File $MYSQL_CONF"
  # ft_min_word_len : Set minimum word length for full-text search
  grep ft_min_word_len 1>/dev/null 2>/dev/null ${MYSQL_CONF}

  if [ "$?" != "0" ] ; then
    echo "[`date +'%Y-%m-%d %H:%M:%S'`] Set ft_min_word_len=1..."
    my_backup=${MYSQL_CONF}.`date +'%Y%m%d%H%M%S'`
    sudo cp ${MYSQL_CONF} $my_backup || handle_error "Can't backup my.cnf!"
    # Append ft_min_word_len=1 after [mysqld]
    sudo sed -e '/^\[mysqld\]/aft_min_word_len=1' $my_backup > /tmp/my.cnf.new || handle_error "Can't add ft_min_word_len to /tmp/my.cnf.new!"
    sudo cp /tmp/my.cnf.new ${MYSQL_CONF} || handle_error "Can't copy /tmp/my.cnf.new to my.cnf!"
    # Restart MySQL
    sudo service mysql restart
  else
    echo "[`date +'%Y-%m-%d %H:%M:%S'`] ft_min_word_len already configured in ${MYSQL_CONF}"
  fi

  # ft_stopword_file : Set custom stopword_file for full-text search (empty)
  grep ft_stopword_file 1>/dev/null 2>/dev/null ${MYSQL_CONF}

  if [ "$?" != "0" ] ; then
    echo "[`date +'%Y-%m-%d %H:%M:%S'`] Set ft_stopword_file='mysql_ft_stopword_file.txt'..."
    my_backup=${MYSQL_CONF}.`date +'%Y%m%d%H%M%S'`
    sudo cp ${MYSQL_CONF} $my_backup || handle_error "Can't backup my.cnf!"
    # Append ft_stopword_file='mysql_ft_stopword_file.txt' after [mysqld]
    sudo sed -e '/^\[mysqld\]/aft_stopword_file="/etc/mysql/mysql_ft_stopword_file.txt"' $my_backup > /tmp/my.cnf.new || handle_error "Can't add ft_min_word_len to /tmp/my.cnf.new!"
    sudo cp `dirname $0`/mysql_ft_stopword_file.txt /etc/mysql/mysql_ft_stopword_file.txt || handle_error "Can't copy mysql_ft_stopword_file.txt to /etc/mysql/mysql_ft_stopword_file.txt!"
    sudo cp /tmp/my.cnf.new ${MYSQL_CONF} || handle_error "Can't copy /tmp/my.cnf.new to my.cnf!"
    # Restart MySQL
    sudo service mysql restart
  else
    echo "[`date +'%Y-%m-%d %H:%M:%S'`] ft_min_word_len already configured in ${MYSQL_CONF}"
  fi

fi # if [ -d /etc/mysql ]

cd `dirname $0`/..