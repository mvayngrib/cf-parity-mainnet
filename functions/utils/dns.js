
const genARecordChangeSet = ({ op, hostedZone, dnsName, ip }) => ({
  HostedZone: hostedZone,
  ChangeBatch: {
    "Comment": `${op} A record of ${dnsName}`,
    "Changes": [
      {
        Action: op,
        ResourceRecordSet: {
          Name: dnsName,
          Type: 'A',
          TTL: 300,
          ResourceRecords: [
            {
              Value: ip
            }
          ]
        }
      }
    ]
  }
})

class DNS {
  constructor(client) {
    this.client = client
  }

  // async listResourceRecordSets ({ hostedZone }) {
  //   return this.client.listResourceRecordSets({ HostedZoneId: hostedZone }).promise()
  // }

  async upsertARecord ({ hostedZone, dnsName, ip }) {
    // aws route53 change-resource-record-sets --hosted-zone-id ${HostedZone} --change-batch file:///home/ec2-user/change-record-set.json
    const params = genARecordChangeSet({ hostedZone, dnsName, ip, op: 'UPSERT' })
    return await this.client.changeResourceRecordSets(params).promise()
  }

  async deleteARecord({ hostedZone, ip }) {
    const params = genARecordChangeSet({ hostedZone, dnsName, ip, op: 'DELETE' })
    await this.client.deleteResourceRecordSets(params).promise()
  }
}

module.exports = opts => new DNS(opts)
