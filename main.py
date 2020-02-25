#!/usr/bin/env python3

from Server import Elections, Patches, Users
from flask import Flask, request, render_template, session, redirect
import pymongo
from pymongo import MongoClient
import json, os
from Crypto.Hash import SHA3_256

app = Flask( __name__
           , static_url_path="/static"
           , static_folder="output/static"
           , template_folder="output")
app.secret_key = os.environ["SECRET_KEY"]

# Errors
ok                      = "0"
catch_all_error         = "1"
invalid_data            = "2"
invalid_context         = "3"
not_logged_in           = "4"

"""
Returns either the login.html
or feed.
If the user is logged in, returns feed
sorted by most recent uploads as
dict of "title" and "hash".
So you can use /read/<hash> to get to reading that upload.
"""
@app.route("/", methods=["GET"])
def index():
    if session.get("username"):
        client      = MongoClient()
        db          = client.demnet
        messages    = db.messages
        messages    = messages.find().sort('upload_time', pymongo.DESCENDING)
        messages_   = []
        for message in messages:
            messages_.append({ "title" : message["title"], "hash" : message["hash"] })

        return render_template("index.html", messages=messages_)
    else:
        return redirect("/login")

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "GET":
        return render_template("login.html")
    elif request.method == "POST":
        username = request.values.get("username")
        password = request.values.get("password")

        if not session.get("keys") and username and password:
            sha3_256 = SHA3_256.new()
            sha3_256.update(password.encode('utf-8'))
            passphrase = sha3_256.hexdigest()
            keys = Users.login(username,passphrase)
            if not keys:
                return invalidData
            else:
                session["keys"] = keys
                session["SHA3-256_passphrase"] = passphrase
                session["username"] = username
                return ok
        else:
            return redirect("/login")

"""
Returns the readings-index.html template
with template argument:
    readings : List[Tuple[title,hash of reading]]

"""
@app.route("/readings", methods=["GET"])
def readings():
    if session.get("username"):
        client      = MongoClient()
        db          = client.demnet
        messages    = db.messages
        readings    = users.find_one({ "username" : session["username" ] })["readings"]
        readings    = [messages.find_one({ "hash" : reading }) for reading in readings]
        readings    = [(reading["body"]["title"], reading["hash"]) for reading in readings]

        return render_template("readings-index.html", readings=readings)
    else:
        return notLoggedIn
"""
Returns the reading.html template
with argument:
    reading, the full message.
"""
@app.route("/read/<reading_hash>", methods=["GET"])
def read(reading_hash):
    if session.get("username"):
        client      = MongoClient()
        db          = client.demnet
        messages    = db.messages
        reading     = messages.find_one({ "hash" : reading_hash })
        return render_template("reading.html", reading=reading)
    else:
        return notLoggedIn

###################################################################
############################ CRITICAL #############################
###################################################################

@app.route("/vote", methods=["POST"])
def vote():
    try:
        app.logger.setLevel(100)

        username = session.get("username")
        election = request.values.get('election')
        vote     = request.values.get('vote')

        if username and election and vote:
            # After this function is called, nobody has any knowledge of the association between user and vote.
            Elections.vote(election, vote, username)

            app.logger.setLevel(0) # The crucial unnoticable part has past.
            # Not even the client is notified, if there was anything wrong, except if they get a timeout.
            return ok
    except Exception as e:
        raise e
    finally:
        return ok

###################################################################
############################ /CRITICAL ############################
###################################################################

@app.route("/message", methods=["POST"])
def message():
    try:
        author      = session["username"]
        body        = json.loads(request.values["body"])
        keys        = session["keys"]

        message     =   { "body"    : body
                        , "from"    : author
                        }

        Users.publish( message, keys )

    except KeyError:
        return invalidData + invalidContext
    except:
        return catch_all_error
    else:
        return ok
