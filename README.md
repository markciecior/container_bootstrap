<h1>README</h1>

<h2>Creating a new guest portal app involves a few steps:</h2>

(1) <i>Create a directory for the persistent database</i><br/>
I've chosen to store the data within /data
<pre>sudo mkdir -p /data/_customer_name_/</pre>

(2) <i>Create a directory for the application data</i><br/>
I've chosen to store the app under /app
<pre>cd /app
mkdir _customer_name_
cd _customer_name_/
</pre>

(3) <i>Pull in the container bootstrap code</i><br/>
This will copy in the necessary files to create a Docker image
<pre>git clone https://github.com/markciecior/container_bootstrap.git .</pre>

(4) <i>Pull in the application code</i><br/>
This will copy in the Python code used to run the website
<pre>git clone 'REPO_NAME' code/guest_portal</pre>

(5) <i>Create the Docker images</i><br/>
The application code will live in one container, the database in another.  We can pull a generic postgres database container from Docker Hub, but we'll build the application image ourselves.
<pre>docker build -t cait/_customer_name_django .</pre>

(6) <i>Set the host as a Swarm manager</i><br/>
This is only done once per host, and has likely been done already
<pre>docker swarm init</pre>

(7) <i>Create a stack of services using the docker-compose YAML file</i><br/>
This YAML file defines what services constitute our application stack.  We're using one DB server and one web/app server.
<pre>stack deploy -c docker-compose.yml _customer_name</pre>

<h2>Additional Info</h2>

<i>To see the stacks deployed on this host:</i>
<pre>docker stack ls</pre>

<i>To see the services (tasks) running for a particular stack:</i>
<pre>docker stack services 'STACK_NAME'</pre>

<i>To see the currently running containers (and their IDs):</i>
<pre>docker container ls</pre>

<i>To see the console output from a running container, using the container ID from the previous command:</i>
<pre>docker logs 2184e2bd9dce #<-- use the container ID here</pre>
