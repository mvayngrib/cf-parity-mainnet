const AWS = require('aws-sdk')
const response = require('cfn-response')
const dns = require('./utils/dns')(new AWS.Route53())
const ec = require('./utils/ec')({
  ecs: new AWS.ECS(),
  ec2: new AWS.EC2(),
})

const prettify = obj => JSON.stringify(obj, null, 2)
const log = (...args) => console.log(...args)
const REQUEST_TYPES = ['Create', 'Update', 'Delete']

const updateDNS = async ({ RequestType, ResourceProperties }) => {
  if (!REQUEST_TYPES.includes(RequestType)) {
    throw new Error(`unexpected RequestType: ${RequestType}`)
  }

  const { cluster, hostedZone, dnsName } = ResourceProperties
  const ips = await ec.getEC2PrivateIps({ cluster })

  log('private ips:', ips.join('\n'))

  const ip = ips[0]

  if (RequestType === 'Create' || RequestType === 'Update') {
    await dns.upsertARecord({ hostedZone, dnsName, ip })
  } else if (RequestType === 'Delete') {
    await dns.deleteARecord({ hostedZone, dnsName, ip })
  }
}

exports.handler = async (event, context) => {
  log('event', prettify(event))

  try {
    await updateDNS(event)
  } catch (err) {
    response.send(event, context, response.FAILED, {
      message: err.message,
      stack: err.stack,
    })

    return
  }

  response.send(event, context, response.SUCCESS, {})
}
