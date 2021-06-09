# Kubernetes Basics
- It is a container orchestration tool
- It is also known as K8s
## Kubernetes Architecture
### Nodes
- A node is a machine where k8s is installed
- It is a worker machine where containers are launched by kubernetes
- Previously nodes were called minions
### Cluster
- It is a set of nodes to fail-safe the containerized application in case 1 or more nodes fail
- Also having more nodes help in sharing loads
### Master
- It is another node where k8s is installed and is configured as a master
- It watches over the nodes in the cluster and is responsible for actual orchestration of the containers on the worker nodes
### Components
- When we install kubernetes, 5 components gets installed with it
1. `API server`
    - acts as a frontend for kubernetes
    - users, management services, cli all talk to API server to interact with cluster
2. `etcd`
    - it is a distributed key-value store to store info used to manage the cluster
    - when you have multiple masters and multiple nodes in a cluster, etcd stores all that info in all the nodes in a distributed manner
    - it is responsible for implementing locks within cluster to ensure any conflict b/w masters
3. `scheduler`
    - responsible for distributing loads for containers across multiple nodes
    - it looks for new created containers and assign them to nodes
4. `controller`
    - brain behind orchestration; responsible for noticing and responding when __nodes, containers and endpoints__ go down
    - makes decision in such cases to bring new containers
5. `container runtime`
    - underlying software for running containers; in our case docker
6. `kubelet`
    - agent that runs on each node in the cluster
    - agent makes sure that the container is running on node as expected

Below image shows the main difference (through the components) b/w master and worker nodes
![master_worker_node](./images/master_worker_node.png)

### kubectl
- it's a command line utility tool; also known as kube control tool
- used to deploy and manage application on kubernetes cluster, to get cluster info, to get status of other nodes in the cluster and manage many other things
- `kubectl run hello-minikube` to deploy application in cluster
- `kubectl cluster-info` to view info about the cluster
- `kubectl get nodes` to list all nodes part of the cluster
-----
## <a id="pods"></a>Pods
- Kubernetes doesn't deploy containers on the worker node; they are wrapped on k8s object called pods
- Pod is a single instance of an application; it has 1-1 relation with application
- Below image shows very simple example of 2 pods on a node and if the node can't take the load of so many users accessing the application, new pod on new node is used
    ![pod_example](./images/pod_example.png)
- You can't have multiple application instances on a singe pod but we can have different container types on same pod as well as mulitple pods on a node
    ![multi_container_pod](./images/multi_container_pod.png)
- `kubectl run nginx --image nginx` will create a pod with name nginx and get image with name "nginx" from docker hub(default lookup) and create container from it
- `kubectl get pods` to list all pods
- `kubectl get pods -o wide` to get slightly detailed info of pods like its IP and node name
- `kubectl describe pod <podname>` detailed description about the pod like its IP, node name, container name, id, its image name, node IP etc.

-----
### Pod in YAML
![yaml_in_k8s](./images/yaml_in_k8s.png)

    - The above image shows an example of how to create a pod using yaml file
    - `apiVersion`, `kind`, `metadata` and `spec` are mandatory fields for creating any k8s objects so start by writing those fields first while creating the file
    - RHS table shows the kinds and their versions to be used in `kind` and `apiVersion` respectively
    - keys for the dictionary in `metadata` are fixed i.e `name` (name of the pod) and `labels` (to identify one pod from another e.g frontend/backend which will help in distinguishing some group of pods from another group) are keywords whereas the keys for the dictionary in `labels` are custom (meaning you can name it anything; just like tag in aws)
    - `spec` info varies depending on the type of object you create; so in this case info about container as we are creating pod
    - `kubectl create -f <filename.yml>` creates the pod object
    - `kubectl apply -f <filename.yml>` same as above (another way of creating object)
    - `kubectl get pods` to list the pods
-----
## Controller (Brain of K8s)
### Replication Controller (new: REPLICA SET) - LOAD BALANCING AND AUTO-SCALING
- replicates the pod (multiple instances of the pod) so as to have __high availablity__ of the running application
- even if you have single pod, replication controller can help in automatically bringing up the new pod if the existing one fails
> Replication Controller ensures the specified number of pods (desired capacity in aws terms) are running whether it's 1 pod or 100
- It helps in load balancing and scaling across nodes as well; see image below
    ![replication_controller_lb_and_as](./images/replication_controller_lb_and_as.png)
- Replication controller is deprecated and the new alternative for it is __REPLICA SET__

### <a id="replicaset"></a>Replica Set in YAML

- Below is an examplle of replica set that creates 3 pods
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
    name: myapp-replicaset
    labels:
        app: myapp
        type: frontend
spec:
    template:  # put pod definition below

        metadata:
            name: myapp-pod
            labels:
                app: myapp
                type: frontend
        spec:
            containers:
            - name: nginx
              image: nginx

    replicas: 3  # desired capacity of pods
    selector:  # which pods to take care of
        matchLabels:
            type: frontend
```
- here the selector property is mandatory and in matchLabels we need to give label of pods that should be included in this replica set
- with selector you can apply different kind of matches to group pods
- with selector, replica set can also manage pods that were not created as part of the template
- `kubectl create -f <replicateset-definition.yml>` to create replicaset object
- `kubectl get replicaset` to see created replicasets
- template section is required so that replicaset can use that definition to create pods when scaling out
- if you provide template and the pods were previously created and running and in `matchLabels` you have those pods then it won't create new pods if the desired capacity is matched
- Similarly if there are more pods than desired which matches the label in replicaset then some of them will be automatically deleted
- 2 options to increase/decrease the number of replicas in future
    1. change the definition file e.g from `replicas: 3` to `replicas: 6` and then use
        `kubectl replace -f <replicateset-definition.yml>`
    2. directly through command which will __NOT__ change the definition file
        `kubectl scale --replicas=6 -f <replicateset-definition.yml>`
                            OR
        `kubectl scale --replicas=6 replicaset myapp-replicaset`
                                      |--> type      |--> name
### Labels and Selectors
- Labels are used so that selectors can filter pods based on matchLabels as there can be 100s of other pods which we may not want to monitor with replicaset
### <a id="replicaset-command"></a>Summary of replicaset commands
```bash
    $ kubectl create -f <example_replica.yml>               # create
    $ kubectl get replicaset                                # check
    $ kubectl replace -f <example_replica.yml>              # edit
    $ kubectl scale --replicas=6 -f <example_replica.yml>   # edit
    $ kubectl edit replicaset <replica_object>              # edit in memory; careful that it doesn't propagate changes to existing replicaset
    $ kubectl delete replicaset myapp-replicaset            # delete; also deletes all underlying PODs
```
> Use `rs` instead of `replicaset` to save time in commandline

> If you run into a scenario where you don't have replicaset definition file but just running object of it, then you can export the definition using
    `kubectl get rs <rs_object> -o yaml > new_replica.yml`
-----
## <a id="deployment"></a>Deployments
- So far we talked about pods which deploy single instance of an application. Each container is encapsulated in such pod. Multiple pods are deployed using replica set
- And then come kubernetes object that comes higher up in hierarchy and provides us the capabilities to
    - upgrade underlying instances seamlessly using `rolling updates`
    - `undo change` (rollback if something went wrong on upgrade), `pause` and `resume` changes (to make all changes together in all instances) as required
- The syntax of deployment object is same as replicaset except the kind value which changes to "Deployment"
- `kubectl create -f <deployment-definition.yml>` to create deployment object
- `kubectl get deployments` to get deployment object
- `kubectl get all` to get all objects i.e deployment, replicaset, pods

### Deployments - Update and Rollback
![deployment_strategy](./images/deployment_strategy.png)
    
    UPDATE:
    1. Recreate
        - first destroy all the instances and then deploy new instances of the application
        - has the side-effect of application downtime

    2. Rolling Update
        - we take down the older version and bring up a newer version one by one
        - application never goes down and the upgrade is seamless
        - this is the default deployment strategy
> Run `kubectl describe depoloyments <deployment_object>` to see the deployment strategy used

> Under the hood, in case of rolling update, k8s create another replicaset and start deploying the applications there and at the same time taking down the applications in the old replicaset. This can be seen with `kubectl get rs` which shows old rs with 0 pods and new rs with desired pods

    ROLLBACK
    - Similarly in case of rollback, k8s restore the previous replicaset and tear down latest rs one by one

### <a id="deployments-command"></a> Deployments Command
- `kubectl create -f <deployment-definition.yml> --record`  to create deployments object (record flag records the command used when we see `describe command`)
- `kubectl get deployments`                                 to get the deployments
- `kubectl apply -f <deployment-definition.yml>`            to update the deployment
- `kubectl rollout status <deployment_object>`              to see the status of the deployment
- `kubectl rollout history <deployment_object>`             to see the revision and history of deployment
- `kubectl rollout undo <deployment_object>`                to rollback deployment operation
-----
## <a id="networking"></a>>Networking
![k8s_network](./images/k8s_network.png)

    - IP Address assigned to the pod is emphemeral
    - When k8s is initially configured, we give it a subnet
![k8s_cluster_network](./images/k8s_cluster_network.png)
    
    - K8s wants us to do the networking so that
        - all containers/pods can communicate to one another without NAT
        - all nodes can communicate with all containers and vice-versa without NAT
    - There are a couple of pre-built solutions available that can do that for us like cisco, flannel etc
![k8s_custom_network](./images/k8s_custom_network.png)
    
    - The above image shows cluster with custom newtwork solution
-----
## <a id="services"></a>Services
![without_service_scenario](./images/without_service_scenario.png)

- Let's consider the scenario in above image that we have developed a web application encapsulated in the pod and deployed in the node.
- The pod has a separate n/w of its own whereas node has an IP of 192.168.1.2
- If we have to access the web application from outside the node say from a machine with IP 192.168.1.10, then one way is to ssh to the node and then use curl to access the pod e.g curl http://10.244.0.2
- But how do we access the application without ssh'ing to the node
- That is where different types of services come into picture
- K8s service is an object just like pods, replicaset and deployment whose one of the use case is to listen to a port in the node and forward that request to the pod running the application. This type of service is called __NODEPORT__ service because the service listens to the port in node

### Service Types
1. NodePort: where the services make internal POD accessible on the port on the NODE
2. ClusterIP: where the service creates a virtual IP inside the cluster to enable communication b/w different services such as set of frontend servers to a set of backend servers
3. LoadBalancer: e.g to distribute load across various servers

### 1. <a id="nodeport"></a>NodePort
![nodeport](./images/nodeport.png)
```yaml
apiVersion: v1
kind: Service
metadata:
    name: myapp-service
spec:
    type: NodePort
    ports:  # it's a list so that we can connect to mulitple pods in the same or different nodes
        - targetPort: 80
          port: 80  # takes value of targetPort if not provided
          nodePort: 30008  # it should only be b/w 30000-32767
    selector:  # should match the labels section of the pod definition
        app: myapp 
        type: front-end
```
- In the nodeport service definition file, targetPort is the only compulsory field. If the value of "port" field is not provided then by default it takes the value of "targetPort". Similarly "nodePort" is given a random value within the emphemeral range "30000-32767"
- `selector` should contain the pod labels so that service can know which pod we're talking about and thus can link to it. If there are 3 pods then the service will link to all the 3 pods if label matches

- `kubectl create -f <service-definition.yml>` to create service
- `kubectl get services` to list the services (or `kubectl get svc`)


- If nodeport service is connected to multiple pods then it uses "random" algo to load balance the app
- If pods are distributed across multiple nodes then service automatically spans across the nodes to laod balance the application<a id="nodeport-loadbalance"></a>

![nodeport_multiple_nodes](./images/nodeport_multiple_nodes.png)

> To summarize nodeport, in any case whether it be single pod on single node or mulitple pods on single node or multiple pods on mulitple nodes, the service is created exactly the same without us having to do anything extra. If the pod is added or deleted the service is automatically updated making it highly adaptive. Once created we don't have to make any further changes.

## 2. <a id="cluster-ip"></a>ClusterIP
![cluster_ip](./images/cluster_ip.png)

    - The above image shows a typical full stack web application and as shown in the image above pods are assigned IP (which are emphemeral)
    - Without cluster ip service it is difficult for a pod in frontend to communicate to backend pod as there is a question of which pod to communicate to and also it might not exist in future 
    - ClusterIP provides a single interface for frontend apps to connect to and the service then takes care of load-balancing to the backend pods. Similary for communication b/w backend and redis in the diagram above
    - Each ClusterIP service gets a name and IP assigned to it and that is the name that other pods should use for communication

```yaml
apiVersion: v1
kind: Service
metadata:
    name: backend
spec:
    type: ClusterIP  # default name if you don't provide this field
    ports:
        - targetPort: 80  # port of pod
          port: 80  # port of service
    selector:  # labels of pods for identifying them
        app: myapp
        type: backend
```

- `kubectl create -f <service-definition.yml>` to create the service object
- `kubectl get services` to list the services

## 3. <a id="load-balancer"></a>LoadBalancer
- We saw that node port is used for connecting external/user facing application to the port on the node
- Also, if node port is used to connect to multiple pods spread across mulitple nodes on a cluster then the user can use the IP of any of the nodes and the node port service will handle the load-balancing (check the image of [NodePort section](#nodeport-loadbalance))
- But it's not ideal way for the users as they have to choose one out of many IPs of the nodes to connect to the application
- The not so best way to solve this would be to have another node/server with nginx and configure load-balancing with it, so that users can use nginx domain name only and nginx load balances for us
- Many major cloud service providers like AWS, GCP, Azure have the in-built loadbalancing feature and thus when we use K8s in those cloud and provide "LoadBalancer" service type definition by just overwriting the `type: NodePort` section of `spec` to `type: LoadBalancer` we can utilise the feature
-----



-----
## SUMMARY
- [Nodes](#nodes)
- [Pods](#pods)
- [ReplicaSet](#replicaset)
    - [ReplicaSet Command](#replicaset-command)
- [Deployments](#deployment)
    - [Deployments Command](#deployments-command)
- [Networking](#networking)
- [Services](#services)
    - [NodePort](#nodeport)
    - [ClusterIP](#cluster-ip)
    - [LoadBalancer](#load-balancer)