## To node or not to node
It is surprisingly hard to run your own Ethereum node. This is why many blockchain-based apps (DApps) defer to someone else running a node for them, e.g. [Etherscan](https://etherscan.io/) or [Infura](https://infura.io/). Yet, if you run an application which, for the life of it depends on the blockchain, you have to live with trusting those third-party services. You will never know if they fed you the wrong transactions, or even the wrong blockchain. Not because they turned evil, may be they were comprormised. All of a sudden, all their clients get compromised too. This defeats the purpose of the blockchain, which is to eliminate centralized intermediaries.

It is surprisingly hard to run your own Ethereum node. This is why we set out to fully automate the process so that our customers

1. can run the node themselves, with close to zero maintenance
2. run it at the lowest cost possible

## Problems we needed to solve

- **Initial sync**. When it starts, it must catch up with all the transactions since the genesis block. It loads all blocks from the other nodes on the network that it can find. Try this on a decent Macbook Pro and after 3 days of that node trying to sync with the blockchain network, you will give up. Not only it is slow, the node sometimes gets stuck and you do not know why. To optimize the sync we run a decent AWS instance (c5.large) with an attached EBS drive with greatly increased IOPS (2500 per second). This baby syncs in about 22 hours (as of September 2018). Then we snapshot the EBS drive, downgrade the machine to a smaller one (t2.medium), and create EBS volume from a snapshot with a lower IOPS. This way the node will sync fast and will cost you only about $100 a month to run.

- **Choosing the software**. Two most popular implementations of Ethereum node (called client) are Geth and Parity. Neither is sufficiently stable. We do not know all the conditions whent they lock up and when they corrupt their databases. But it happens and we need a managable solution to address this problem. And this is just the trouble without updating their software.

- **Networking**. Ethereum node works behind the firewall. Specifically you do not need to open any ports. But if you do not, the speed of syncing suffers greatly as it can only talk to the public nodes, and the majority of nodes on the Ethereum network are not public. In addition, if you are running a node in production environment, you do not want any surprises, so you need to isolate it from the rest of the stack. This is where AWS VPC (software defined network) comes in.

## Not enough functionality 
Ethereum node provided JSON-RPC interface that allows basic queries of the database, which it creates when loading all the blocks. We needed other queries against this database, but there is not mechanism to add additional indexes for such queries not to run for hours.

Specifically at this point we need to get all transactions for a specific address. In the future we may need other queries.

We had no choice but to repeat the work of reading ALL the blocks again. We run a separate container and talk an Ethereum node, running in a separate container, via its JSON-RPC. As we read the blocks we index them into a leveldb database. We also defined REST API to query this index and proxy a subset of JSON-RPC calls into an Ethereum node, so it is a superset of normal Ethereum JSON-RPC interface. It takes about 3 hours (in the Ethereum state as of September 2018) to load this index.

We call this component the Indexer.

## Cloudformation Stack for Ethereum Parity Node

We evaluated several options for running an Ethereum node in the cloud. The criteria we considered were:

- how to adhere to the infrastructure-as-code paradigm, i.e. how do we make it more like a managed Ethereum service than an EC2 machine you need to SSH into for maintenance
- how to recover from failures?
- how to enable automatic or one-click updates?
- how to secure the node?

We looked at several solutions, including [AWS's Blockchain Templates](https://aws.amazon.com/blockchain/templates/) and an [open source solution created by a group called Rumble Fish Blockchain Development](https://www.rumblefishdev.com/how-to-run-ethereum-mainnet-node-on-aws/), and came up with a hybrid.

The AWS Blockchain Templates were quite sophisticated, but it wasn't clear how they managed the chain data, and how to set up "checkpointing," in case of failures. They also used a custom AWS docker images for the Ethereum client; we'd rather use the ones provided by the Geth and Parity communities.

The Rumble Fish templates were simpler to understand, but launched in the default VPC, didn't create networking infrastructure necessary for isolating things for security, and was designed to scale with the help of an additional cloudformation stack more specific to their use case.

The result is a cloudformation stack that uses Elastic Container Service to deploy one or more containerized parity nodes behind a load balancer inside a VPC. An additional container runs alongside to build the additional indexes MyCloud needs to query. For extra security, the node itself is accessible only to the Indexer. This way you know, that no other DApp is munching off of your Ethereum node, which costs you money to run, and that it is fully protected from DDOS. The Indexer's REST API sits behind an nginx container that can be configured to check an Authorization header for an API key.

###The stack has several nested stacks

- VPC stack with 2 public and 2 private subnets
- ECS stack that defines the container cluster, specs for creating instances on which containers run (EC2 machines), the configuration for auto-scaling, and data volumes to persist data.
- the Ethereum stack, which describes which containers to run, essentially an analogue of a docker-compose.yml file.
- security groups stack
- load balancer stack
- optional SSH bastion host
- optional DNS stack, in case you want to call parity.example.com instead of a frankenstein aws load balancer url (e.g.  parity-ropsten-2-123uio.elb.amazonaws.com).

###The stack is parametrized 
It can be launched against ropsten or kovan. The underlying EC2 instance type can likewise be configured. (See Parameters in cloudformation/main.yml).

The modularization of the stack into multiple components makes for something easier to understand, with reusable parts.

Misc: the stack can optionally take a snapshot of the data volume after the first sync and notify the admin. This provides a kind of "checkpoint" to come back to in case something goes wrong.

## current limitations 

- We do not have 100% automation yet when switching from the initial sync mode. 
- For security reasons we only proxy a small whitelist of JSON-RPCs from Indexer into the Ethereum node. This list can be extended later. 
- It is a separate stack. We do not have an integration into MyCloud stack yet.
- Add snapshots on a regular basis so that you can start from the last working one and catch up to the latest blocks quickly.
- Detect that the node got stuck, kill it, and restart with the lastest snapshot.

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

## Development

1. copy `scripts/env-sample.sh` -> `scripts/env.sh` and adjust per your environment
1. `scripts/build_and_upload.sh [repo-name] [path-to-Dockerfile]` will build the image and push it to ECR
1. `scripts/create-or-update-stack.sh` - validate + upload cloudformation templates, and create/update your Ethereum stack

### Utils

- `scripts/restart-task.sh` will force the ECS task to restart, picking up any new image you pushed to ECR
1. `scripts/delete-and-create-stack.sh` - just what it says :)
