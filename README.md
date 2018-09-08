## Cloudformation Stack for Ethereum Parity Node

We evaluated several options for running an Ethereum node in the cloud. The criteria we considered were:

- how to adhere to the infrastructure-as-code paradigm, i.e. how do we make it more like a managed Ethereum service than an EC2 machine you need to SSH into for maintenance
- how to make it cloneable, like MyCloud
- how to recover from failures?
- how to enable automatic or one-click updates?
- how to secure the node?

We looked at several solutions, including AWS's Blockchain Templates and an open source solution created by a group called Rumble Fish Blockchain Development, and came up with a hybrid.

The result is a cloudformation stack that uses Elastic Container Service to deploy one or more containerized parity nodes behind a load balancer inside a VPC. An additional container runs alongside to build the additional indexes MyCloud needs to query. The node itself is accessible only to the indexer. The indexer's REST API sits behind an nginx container that can be configured to check an Authorization header for an API key.

The stack has several nested stacks:
- VPC stack with 2 public and 2 private subnets
- ECS stack that defines the container cluster, specs for creating instances on which containers run (EC2 machines), the configuration for auto-scaling, and data volumes to persist data.
- the Ethereum stack, which describes which containers to run, essentially an analogue of a docker-compose.yml file.
- security groups stack
- load balancer stack
- optional SSH bastion host
- optional DNS stack, in case you want to call parity.example.com instead of a frankenstein aws load balancer url

The modularization of the stack into multiple components makes for something easier to understand, with reusable parts.

Misc: the stack can optionally take a snapshot of the data volume after the first sync and notify the admin. This provides a kind of "checkpoint" to come back to in case something goes wrong.
