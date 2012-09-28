#!/bin/bash
ls -1 pascal |grep "pas" |  while read i; do ./compilador pascal/$i; done  | grep syntax
