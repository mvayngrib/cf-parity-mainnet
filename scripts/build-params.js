const fs = require('fs')
const path = require('path')
const fetch = require('node-fetch')
let [paramsFile, templateDir] = process.argv.slice(2)
if (!paramsFile) {
  throw new Error(`expected base params file as first arg`)
}

paramsFile = path.resolve(__dirname, paramsFile)
if (!fs.existsSync(paramsFile)) {
  throw new Error(`file does not exist: ${paramsFile}`)
}

const log = (...args) => console.log(...args)
const prettify = obj => JSON.stringify(obj, null, 2)
const prettyPrint = obj => log(prettify(obj))

const loadEnv = () => fs.readFileSync(path.join(__dirname, 'env.sh'), { encoding: 'utf-8' })
  .split('\n')
  .map(s => s.replace(/^export\s+/, '').trim().split('='))
  .reduce((map, [k, v]) => {
    map[k] = v
    return map
  }, {})

const getCurrentBlock = async () => {
  const res = await fetch('https://api.etherscan.io/api?module=proxy&action=eth_blockNumber')
  const { result } = await res.json()
  return parseInt(result.slice(2), 16)
}


const build = async paramsFile => {
  const params = require(paramsFile).slice()
  const getParam = key => params.find(p => p.ParameterKey === key)
  const { NETWORK } = loadEnv()
  const syncToBlockParam = getParam('SyncToBlock')
  if (!syncToBlockParam) {
    params.push({
      ParameterKey: 'SyncToBlock',
      ParameterValue: String(await getCurrentBlock())
    })
  }

  const netParam = getParam('NetworkName')
  if (!netParam) {
    params.push({
      ParameterKey: 'NetworkName',
      ParameterValue: NETWORK
    })
  }

  const dnsParam = getParam('DNSName')
  if (!dnsParam) {
    params.push({
      ParameterKey: 'DNSName',
      ParameterValue: `eth-${NETWORK}.mvayngrib.com`
    })
  }

  const tDir = getParam('S3TemplatesPath')
  if (!tDir) {
    params.push({
      ParameterKey: 'S3TemplatesPath',
      // trim begin/end slashes
      ParameterValue: templateDir
        .replace(/^[/]+/, '')
        .replace(/[/]+$/, '')
    })
  }

  return params
}

build(paramsFile).then(prettyPrint, console.error)
