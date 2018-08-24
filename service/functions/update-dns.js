const AWS = require('aws-sdk')
const response = require('../cfn-response')
const dns = require('../dns')(new AWS.Route53())
const ec = require('../ec')({
  ecs: new AWS.ECS(),
  ec2: new AWS.EC2(),
})

const prettify = obj => JSON.stringify(obj, null, 2)
// eslint-disable-next-line no-console
const log = (...args) => console.log(...args)
const REQUEST_TYPES = ['Create', 'Update', 'Delete']

const updateDNS = async ({ RequestType, ResourceProperties, OldResourceProperties }) => {
  if (!REQUEST_TYPES.includes(RequestType)) {
    throw new Error(`unexpected RequestType: ${RequestType}`)
  }

  const { cluster, hostedZone, dnsName } = ResourceProperties
  const ips = await ec.getEC2PrivateIps({ cluster })

  log('private ips:', ips.join('\n'))

  const ip = ips[0]

  if (RequestType === 'Create') {
    await dns.upsertARecord({ hostedZone, dnsName, ip })
  } else if (RequestType === 'Update') {
    if (OldResourceProperties.hostedZone !== hostedZone || OldResourceProperties.dnsName !== dnsName) {
      await dns.deleteARecord({
        hostedZone: OldResourceProperties.hostedZone,
        dnsName: OldResourceProperties.dnsName,
        ip
      })
    }

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
    return await response.send(event, context, response.FAILED, {
      message: err.message,
      stack: err.stack,
    })
  }

  return await response.send(event, context, response.SUCCESS, {
    hooray: true
  })
}
