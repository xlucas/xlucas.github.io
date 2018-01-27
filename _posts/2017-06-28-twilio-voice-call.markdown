---
title: Automatic outgoing voice calls with Twilio
teaser: Use Twilio API to programmatically send voice calls with text-to-speech.
image: /images/logo.png
comments: true
category: guides
tags: [twilio, python]
---

## About Twilio
[Twilio][twilio-com] is a cloud communications platform providing a complete
[API][twilio-api] to manage SMS, Voice & Messaging. It has a free tier that
makes it possible for everyone to test their services with few reasonable
limitations, and provides test credentials to test your applications without
draining your account usage. The API comes with several SDKs for various
programming languages. In this article we use the Python version.

## Using Twilio API
It's pretty simple: register a free account and you will be given a Service ID
(SID) and a token. Install the SDK with `pip install twilio` then pass these
informations to the Twilio client object.

```python
from twilio.rest import Client

sid = 'valsb7isizln0lfpdcdweo1mfob1ihfgli'
token = 'z5xfvjv529zafqgv93mbry94rfpx8lsy'

client = Client(sid, token)
client.do_something(...)
```

## How does a voice call work
Firsteval, you start a voice call with a simple API request, and you supply
some obvious parameters like the origin phone number and destination phone
number. To trigger actions during the call, Twilio needs to know what to do.
When you trigger a voice call you have to give it a URL. During the call a
request will be sent to this URL, expecting as a result a XML formatted
response honoring Twilio's scheme called [TwiML][twilio-twiml].
<div align="center">
	<p>
		<image src="/images/twilio-call.png" alt="Twilio call"/>
	</p>
</div>


## Adding a voice call capable phone number
The free tier gives you access to one voice call & fax capable phone number.
You can order additional phone numbers with different capabilities for an
affordable extra fee. This phone number will be used as the origin for outgoing
phone calls.
<div align="center">
	<p>
		<image src="/images/twilio-phone-number.png" alt="Twilio phone number"/>
	</p>
</div>


## Creating a TwiML bin
Hopefully, for a basic usage you don't need to host your own web server anymore
to host the call controller, you can use [TwiML Bin][twilio-bin] instead. For
non trivial usage you may need to stick with hosting your own API and passing
it to outgoing phone calls.
<div align="center">
	<p>
		<image src="/images/twilio-bin.png" alt="Twilio TwiML bin"/>
	</p>
</div>

## Automate phone calls
Now we only need to trigger voice calls with the SDK.

```python
import argparse
import sys
from twilio.rest import Client


def parse_args():
    parser = argparse.ArgumentParser(description='A tool to send voice calls')

    auth = parser.add_argument_group('Authentication')
    auth.add_argument('--sid', required=True, help='Account SID')
    auth.add_argument('--token', required=True, help='Auth token')

    call = parser.add_argument_group('Call')
    call.add_argument('--from', metavar='NUMBER', dest='from_', required=True)
    call.add_argument('--to', metavar='NUMBER', required=True)
    call.add_argument('--url', required=True, help='Call handler URL')

    return parser.parse_args()


def main():
    args = parse_args()

    client = Client(args.sid, args.token)
    client.api.account.calls.create(to=args.to, from_=args.from_, url=args.url)


if __name__ == '__main__':
    sys.exit(main())
```

## Testing
Let's run the script from the command line:

```bash
python main.py \
--sid 'valsb7isizln0lfpdcdweo1mfob1ihfgli' \
--token 'z5xfvjv529zafqgv93mbry94rfpx8lsy' \
--from '+33987654321' \
--to '+33123456789' \
--url 'https://handler.twilio.com/twiml/EH3bc7d457af2e3da770c7382ab4a9f919'
```

Here you go:
<div align="center">
	<p>
		<image src="/images/twilio-result.png" alt="Twilio result"/>
	</p>
</div>

Pick up the call and you will hear a text to speech record greeting you with a
'Hello World!'.


[twilio-api]: https://www.twilio.com/docs/api/rest
[twilio-bin]: https://www.twilio.com/console/dev-tools/twiml-bins
[twilio-com]: https://www.twilio.com
[twilio-twiml]: https://www.twilio.com/docs/api/twiml
