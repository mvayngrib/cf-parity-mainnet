
const genARecordChangeSet = ({ op, hostedZone, dnsName, ip }) => ({
  HostedZoneId: hostedZone,
  ChangeBatch: {
    Comment: `${op} A record of ${dnsName}`,
    Changes: [
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

  async listResourceRecordSets ({ hostedZone }) {
    return await this.client.listResourceRecordSets({ HostedZoneId: hostedZone }).promise()
  }

  async upsertARecord (opts) {
    await this._changeARecord({ ...opts, op: 'UPSERT' })
  }

  async deleteARecord(opts) {
    await this._changeARecord({ ...opts, op: 'DELETE' })
  }

  async _changeARecord(opts) {
    const params = genARecordChangeSet(opts)
    await this.client.changeResourceRecordSets(params).promise()
  }
}

module.exports = opts => new DNS(opts)
