#!C:/Python27/python.exe
# -*- coding: iso-8859-15 -*-

import sys
import cgi

fs = cgi.FieldStorage()

# -------------------------
# ### ServerCode ###
# -------------------------

print "Content-Type: text/plain\n"

functionname = fs["request"].value
function = locals()[functionname]
sys.stdout.write(function())




#for key in fs.keys():
#    print "%s = %s" % (key, fs[key].value)