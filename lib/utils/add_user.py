import json
import requests
import sys

url = f'https://firestore.googleapis.com/v1/projects/grocerylistapp-bf738/databases/(default)/documents/authors/{sys.argv[1]}?updateMask.fieldPaths=authors_following&updateMask.fieldPaths=recipes_following&updateMask.fieldPaths=checklist'
body = json.dumps({ 
  "fields": { 
    "authors_following" : { "arrayValue" : {"values": []}},
    "recipes_following" : { "arrayValue" : {"values": []}},
    "checklist" : { "arrayValue" : {"values": []}}
  }
})

x = requests.patch(url, data=body)
print(x.status_code)
print(x.text)
