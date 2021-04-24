# Nginx timeout and Port Forwarding 

I recently (relative term by the way) had to perform confluence space migration from one domain to another. In order to do so I had to upload confluence xml content (backup restoration) to the app's UI. More details about how to do that is explained ![here](https://support.atlassian.com/confluence-cloud/docs/import-a-confluence-cloud-space/).

Now, if the xml file is smaller is size less than 500MB then it's fairly easy to export. But in my case it was 3.7GB. 

The infrastructure that we use for confluence is something like this - 
* We have nginx server that acts as a load balancer and 2 confluence nodes as the backend server

When we are uploading the content to confluence server, there's a high chance that we get nginx timeout if the network bandwidth is low. We can, in this case, either change the nginx configuration - increase the timeout, or directly access the confuence server to upload the content instead of using nginx as the middleman.

I chose the later approach to directly access one of the confluence node by making use of nginx `proxy_pass` to another port set in the nginx `conf` file.

In order to directly upload the content to the confluence server I used port forwarding using ssh (as I am using Ubuntu machine).

`ssh -L localhost:<port>:<confuence_server_ip_or_hostname>:<proxy_port> root@<confluence_server_ip_or_hostname>`

With above command I was able to access the confluence server UI locally in a browser. Now, I can comfortably upload the xml file stored locally into the localhost browser setup.
