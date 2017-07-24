#!C:/Python27/python.exe
# -*- coding: iso-8859-15 -*-

import sys
import cgi

fs = cgi.FieldStorage()

# -------------------------
# ### ServerCode ###
# -------------------------

print "Content-Type: text/plain\n"
print "Access-Control-Allow-Origin:*\n"

functionname = fs["request"].value
function = locals()[functionname]
sys.stdout.write(function())
