## Cloudformation Stack for Ethereum Parity Node

We evaluated several options for running an Ethereum node in the cloud. The criteria we considered were:

- how to adhere to the infrastructure-as-code paradigm, i.e. how do we make it more like a managed Ethereum service than an EC2 machine you need to SSH into for maintenance
- how to recover from failures?
- how to enable automatic or one-click updates?
- how to secure the node?

We looked at several solutions, including AWS's Blockchain Templates and an open source solution created by a group called Rumble Fish Blockchain Development, and came up with a hybrid.

The AWS Blockchain Templates were quite sophisticated, but it wasn't clear how they managed the chain data, and how to set up "checkpointing," in case of failures. They also used a custom AWS docker images for the Ethereum client; we'd rather use the ones provided by the Geth and Parity communities.

The Rumble Fish templates were simpler to understand, but launched in the default VPC, didn't create networking infrastructure necessary for isolating things for security, and was designed to scale with the help of an additional cloudformation stack more specific to their use case.

The result is a cloudformation stack that uses Elastic Container Service to deploy one or more containerized parity nodes behind a load balancer inside a VPC. An additional container runs alongside to build the additional indexes MyCloud needs to query. The node itself is accessible only to the indexer. The indexer's REST API sits behind an nginx container that can be configured to check an Authorization header for an API key.

The stack has several nested stacks:
- VPC stack with 2 public and 2 private subnets
- ECS stack that defines the container cluster, specs for creating instances on which containers run (EC2 machines), the configuration for auto-scaling, and data volumes to persist data.
- the Ethereum stack, which describes which containers to run, essentially an analogue of a docker-compose.yml file.
- security groups stack
- load balancer stack
- optional SSH bastion host
- optional DNS stack, in case you want to call parity.example.com instead of a frankenstein aws load balancer url (e.g.  parity-ropsten-2-123uio.elb.amazonaws.com).

The stack is parametrized. It can be launched against ropsten or kovan. The underlying EC2 instance type can likewise be configured. (See Parameters in cloudformation/main.yml).

The modularization of the stack into multiple components makes for something easier to understand, with reusable parts.

Misc: the stack can optionally take a snapshot of the data volume after the first sync and notify the admin. This provides a kind of "checkpoint" to come back to in case something goes wrong.

## Todo

the big problem is attaching the data volume on a new instance's start, when it might already be taken by the instance we are replacing. Normally, to prevent downtime, the new instance needs to be up before the old one is taken down.

### Goals for auto-scaling
- survice
- don't fall too far behind the chain (i.e. don't use an old snapshot)
- minimize downtime

### Ideas
- on start, create a snapshot from the running instance's volume, create a new volume, attach it, initialize it, sync.

### Questions

if during auto-scaling, the new instance is in a different AZ, it'll need to attach to a different EBS volume than the running instance

### Reading Material

initializing volume faster:
https://stackoverflow.com/questions/46284897/optimize-big-ebs-volumes-initialization-warm-up

lifecycle hooks:
https://linuxacademy.com/blog/amazon-web-services-2/understand-lifecycle-hooks/
  
  maybe using lifecycle hooks we could catch the 2nd instance starting up, and shut down the first instance before letting the 2nd proceeed (so that the 2nd can connect to the volume)

what about availability zones? What if 2nd instance starts in another availability zone

need