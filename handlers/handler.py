import json

def hello(event, context):
    print("Lambda Task")
    response = {
        "message": "Hello World",
        "country": "Mx",
        "jobQueNames": ['job1', 'job2', 'job3']
    }
    return response
