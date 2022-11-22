#!/bin/bash

# Script arguments prefixed with -- are converted into script variables.
# The -- prefix is stripped and dashes are replaced with underscores.
# --some-arg=value => $some_arg=value
# --no-value-arg => $no_value_arg=_
#
# We set an underscore _ char as value to the $no_value_arg in order 
# to make conditional checks easier:
# [[ "$no_value_arg" ]] && echo "arg present"
# [[ "$no_value_arg" ]] || echo "arg missing"
#

while [[ $# -gt 0 ]]; do
  [[ "$1" =~ ^[--] && "${1#--}" ]] || { shift; continue; }

  argument_split=( ${1/=/ } )

  variable_name="$( echo "${argument_split[0]#--}" | tr '-' '_' )"
  variable_value="${argument_split[1]:-"_"}"

  # Safe eval => http://mywiki.wooledge.org/BashFAQ/006#eval
  eval "${variable_name}=\$variable_value"

  shift
done
