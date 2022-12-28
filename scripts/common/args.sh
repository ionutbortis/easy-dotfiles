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

  read -ra argument_split <<< "${1/=/ }"

  variable_name="$(echo "${argument_split[0]#--}" | tr '-' '_')"
  variable_value="${argument_split[1]:-"_"}"

  # Safe eval => http://mywiki.wooledge.org/BashFAQ/006#eval
  eval "${variable_name^^}_ARG=\$variable_value"

  shift
done
