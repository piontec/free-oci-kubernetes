# Design decisions and considerations

## Storage and nodes

The free tier of OCI allows only for 4 volumes of total size of 200 GB. Each node must have a single OS dedicated
volume of size at least 50 GB. With this in mind, I decided to use only 2 nodes, and give each one of them one
50 GB boot volume and one additional 50 GB volume for data storage, that is automatically detected and attached
to a cluster node on boot (so when you roll nodes, the volume can be automatically moved from the old node to the
new one). With this limited size of data volumes, there's no point in running any distributed storage system, so
all the persistent data is used as a regular node-local storage volume. This means, that if your applications need
any persistent volumes (PV) or claims (PVCs), they can only use the volume that is attached to the current node.
The necessary `storage class` is already available and created by the code.

You don't have to worry about detaching and re-attaching the data volumes on node's failure or rotation. The
setup uses 2 Availability Domains and runs 1 node in each of them. Then, it also creates 1 data volume
in each AD. Each node on boot discovers the designated data volume from the same AD and attaches it on boot,
so even if a node is terminated, the drive will be attached again to the new node.

## Load Balancer

OCI offers 1 free load balancer of type NLB. As such you can have only 1 Service of type `LoadBalancer`.
In this setup, there's already `nginx-ingress` controller using it, so if you want to keep your cluster free,
you should create all the services using `ClusterIP` type and expose them using an `Ingress`.
