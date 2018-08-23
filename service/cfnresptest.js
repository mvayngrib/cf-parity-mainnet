// const response = require('cfn-response')

// response.send({
//     "RequestType": "Delete",
//     "ServiceToken": "arn:aws:lambda:us-east-1:404247308186:function:MainnetParity2-us-east-1-update-dns",
//     "ResponseURL": "https://cloudformation-custom-resource-response-useast1.s3.amazonaws.com/arn%3Aaws%3Acloudformation%3Aus-east-1%3A404247308186%3Astack/MainnetParity2/e0bdffc0-a4ee-11e8-8a1e-500c286e44d1%7CDNSUpdater%7Cb74e2121-ebfb-4851-a8dc-aac8fe8f11ea?AWSAccessKeyId=AKIAJEMEJLKI636XPIMQ&Expires=1534828346&Signature=1jW%2Fm3zAcLgbjHclVHGmxJAwH50%3D",
//     "StackId": "arn:aws:cloudformation:us-east-1:404247308186:stack/MainnetParity2/e0bdffc0-a4ee-11e8-8a1e-500c286e44d1",
//     "RequestId": "b74e2121-ebfb-4851-a8dc-aac8fe8f11ea",
//     "LogicalResourceId": "DNSUpdater",
//     "PhysicalResourceId": "MainnetParity2-DNSUpdater-1JJKJOMHL14SF",
//     "ResourceType": "Custom::DNSUpdater",
//     "ResourceProperties": {
//         "ServiceToken": "arn:aws:lambda:us-east-1:404247308186:function:MainnetParity2-us-east-1-update-dns",
//         "cluster": "MainnetParity2",
//         "hostedZone": "ZPADEKO76QP6O",
//         "snapshotId": "",
//         "dnsName": "ethmainnet2.mvayngrib.com"
//     }
// }, {
//   done: (err, result) => {
//     debugger
//   }
// }, response.SUCCESS, {
//   hooray: true
// })
