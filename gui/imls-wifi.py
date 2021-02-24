import json
import requests

key = "eQ3hlNegA9SGXgOfeSY2ixTZAkYPivdZ"
host = "http://localhost:8000"
interview = "docassemble.imlswirelessinterview:data/questions/wireless.yml"

# first, retrieve a new session
resp = requests.get(f"{host}/api/session/new",
                    {"key": key, "i": interview})
values = resp.json()
session = values['session']
secret = values['secret']

data = {"key": key, "i": interview, "session": session, "secret": secret}

resp = requests.get(f"{host}/api/session/question", data)
fields = resp.json()
question = fields["questionName"]
print(fields["questionText"])
# first: Welcome!

variables = dict()
variables["intro_screen"] = True
data["question_name"] = question
resp = requests.post(f"{host}/api/session", data={"variables": json.dumps(variables), **data})
fields = resp.json()
question = fields["questionName"]
print(fields["questionText"])
# second: How many wifi sessions did you see in the last calendar year?

variables["wifi_sessions"] = 100000
data["question_name"] = question
resp = requests.post(f"{host}/api/session", data={"variables": json.dumps(variables), **data})
fields = resp.json()
question = fields["questionName"]
print(fields["questionText"])
# third: Which state are you submitting data on behalf of?

variables["state"] = "California"
data["question_name"] = question
resp = requests.post(f"{host}/api/session", data={"variables": json.dumps(variables), **data})
fields = resp.json()
question = fields["questionName"]
print(fields["questionText"])
# fourth: Thank you!

print(resp.json())
