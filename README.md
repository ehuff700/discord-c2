# discord-c2
This is a demonstration of how the Discord chat services platform can be used for exfiltrating data and staging payloads.


## Setup - Powershell
First, unzip the git and open up the stager.ps1 file in the code editor of your choice. The variables that will need changing are **$hookUrl and $cdnURL**

Then, you must generate your discord webhook, which will be used to POST (exfiltrate) data from your victim client. To create a webhook, abide by the following steps:

1. Create a new Discord server, with the name of your choosing.

2. Create a new channel, or use the existing "general" and navigate to the channel settings by clicking on the "Edit Channel" cog.

3. On the new popup, navigate to Integrations, then click on "Create Webhook". You can name this integration whatever you'd like, and even choose a picture for it. Once you are done please assign the variable **$hookUrl** in stager.ps1 to the value of your webhook URL.

![image](https://user-images.githubusercontent.com/125618371/226067071-885668ba-4e1d-48b4-b70f-b74aedb8e360.png)

4. In the same channel as previously, or in a new channel, upload the discord.ps1 file. This file is used to import some functions for discord communication that don't really belong in the main script.

6. Right click on the download button of your newly-uploaded discord.ps1 file, and click "Copy Link".

![image](https://user-images.githubusercontent.com/125618371/226066946-495c76c7-5f4c-44ff-a9c1-0da9411773b8.png)

7. Go back to stager.ps1, and assign the variable $cdnURL to the link you just copied.

8. Feel free to read the documentation for discord.ps1 to understand what the commands do/how they work, but assuming all is setup correctly, running stager.ps1 on the client will send the message and the log file to the discord channel that is hosting your webhook.


# How it works
Discord has a public-facing CDN (Content Delivery Network) that uses a schema in the following format to host files: **hxxps://cdn[dot]discord[dot]com/CHANNEL_ID/?/FILE_NAME** (Explanation of parameters below). Because of the nature of Discord, it allows you to host files, images, videos, etc through their platform. But because their CDN has a predictable format and allows you to directly copy the link to the file, anyone outside of discord with the CDN link to the file can download it directly, without requiring any sort of authentication whatsoever. This makes it an invaluable tool for dropping second stage payloads (such as how stager.ps1 downloads discord.ps1 to use additional functionality). Not to mention that Discord traffic is encrypted HTTPS traffic over 443, which is allow-listed in nearly every environment ever. Quite concerning if you ask me. 

The actual script itself works by sending a POST request to the webhook, which in turn creates the message within the discord channel you created the webhook integration for. [Webhooks](https://www.redhat.com/en/topics/automation/what-is-a-webhook) are great and can be used for a bunch of amazing things, but in this particular context it can be used to exfiltrate data quickly and efficiently, over standard ports to a non-malicious and non-conspicuous domain. As such, this method is infinitely better than hosting your own C2 infrastructure, spinning up a suspicious, newly created domain over random ephemeral ports which would be flagged by nearly any high-quality firewall.

**CHANNEL_ID**

To retrieve the ID of a channel, enable [Developer Mode](https://www.howtogeek.com/714348/how-to-enable-or-disable-developer-mode-on-discord/) on Discord, right click directly on a channel, and that will be the unique ID of the channel.

**?**

I am not entirely sure how this ID is generated but I believe this is the unique epoch timestamp, with some extra funk, in the format of Twitter's [Snowflake ID Generation](https://en.wikipedia.org/wiki/Snowflake_ID)


