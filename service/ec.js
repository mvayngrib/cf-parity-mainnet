// const listTasksInCluster = async cluster => {
//   const { taskArns } = await ecs.listTasks({ cluster }).promise()
//   const { tasks } = await ecs.describeTasks({
//     tasks: taskArns,
//   }).promise()

//   return tasks
// }

const flatten = arr => [].concat.apply([], arr)
// eslint-disable-next-line no-console
const log = (...args) => console.log(...args)

class EC {
  constructor({ ecs, ec2 }) {
    this.ecs = ecs
    this.ec2 = ec2
  }

  async listContainerInstances ({ cluster }) {
    const { ecs } = this
    const { containerInstanceArns } = await ecs.listContainerInstances({ cluster }).promise()
    log(`found ${containerInstanceArns.length} container instances in cluster: ${cluster}`, containerInstanceArns)

    const { containerInstances } = await ecs.describeContainerInstances({
      cluster,
      containerInstances: containerInstanceArns,
    }).promise()

    return containerInstances
  }

  async getEC2Instances ({ instanceIds }) {
    const { ec2 } = this
    const { Reservations } = await ec2.describeInstances({ InstanceIds: instanceIds }).promise()
    const instances = Reservations.map(r => r.Instances)
    return flatten(instances)
  }

  async getEC2PrivateIps ({ cluster }) {
    const containers = await this.listContainerInstances({ cluster })
    const instanceIds = containers.map(c => c.ec2InstanceId)
    log(`found ${instanceIds.length} ec2 instances in cluster: ${cluster}`, instanceIds)

    const instances = await this.getEC2Instances({ instanceIds })
    const ips = instances.map(i => i.PrivateIpAddress)
    return ips
  }
}

module.exports = opts => new EC(opts)
