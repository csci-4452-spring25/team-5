# Repository containing our Music (Ampache) group project.

###### Resources
[https://github-wiki-see.page/m/ampache/ampache/wiki/Installation](https://github-wiki-see.page/m/ampache/ampache/wiki/Installation "https://github-wiki-see.page/m/ampache/ampache/wiki/Installation")
[https://github.com/ampache/ampache/wiki/Installation](https://github.com/ampache/ampache/wiki/Installation "https://github.com/ampache/ampache/wiki/Installation")

**4/21/24**
Docker is currently working, and able to succefully deploy the Ampache instance succefully. Now we must figure out how edit the configuration options to have the setup-presets working via a preconfig file directly from the EC2 instance.

There is also the issue of storage; the database used currently is just for metadata (mariaDB). To actually store the content and have it accessable via the cloud (non-local to just the EC2), we need to figure out a solution. 
###### Currently, using Amazon S3 seems like the likely choice.