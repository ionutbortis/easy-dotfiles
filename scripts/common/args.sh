#!/bin/bash

# Script arguments prefixed with -- are converted into script variables.
# The -- prefix is stripped, dashes are replaced with underscores, 
# letters are converted to UPPERCASE and the "_ARG" suffix is added.
# --some-name=value => $SOME_NAME_ARG=value
# --no-value => $NO_VALUE_ARG=_
#
# We set an underscore _ char as value to the $NO_VALUE_ARG in order 
# to make conditional checks easier:
# [[ "$NO_VALUE_ARG" ]] && echo "arg present"
# [[ "$NO_VALUE_ARG" ]] || echo "arg missing"
#

while [[ $# -gt 0 ]]; do
  [[ "$1" =~ ^[--] && "${1#--}" ]] || { shift; continue; }

  read -ra arg_split <<< "${1/=/ }"

  var_name="$(echo "${arg_split[0]#--}" | tr '-' '_')"
  var_value="${arg_split[1]:-"_"}"

  # Safe eval => http://mywiki.wooledge.org/BashFAQ/006#eval
  eval "${var_name^^}_ARG=\$var_value"

  shift
done

unset arg_split var_name var_value
