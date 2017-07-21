from flask import Flask, render_template, jsonify, request
from time import *

app = Flask(__name__)

@app.route('/')
def entry():
 return render_template('index.html')

# -------------------------
# ### PB2Web ServerCode ###
# -------------------------

if __name__ == "__main__":
    app.run(debug=True, port=#FLASKPORT#)