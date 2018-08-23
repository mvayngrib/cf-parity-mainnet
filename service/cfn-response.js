/* Copyright 2015 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
   This file is licensed to you under the AWS Customer Agreement (the "License").
   You may not use this file except in compliance with the License.
   A copy of the License is located at http://aws.amazon.com/agreement/.
   This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or implied.
   See the License for the specific language governing permissions and limitations under the License. */

exports.SUCCESS = "SUCCESS";
exports.FAILED = "FAILED";

exports.send = function(event, context, responseStatus, responseData, physicalResourceId) {
  return new Promise((resolve, reject) => {

    var responseBody = JSON.stringify({
              Status: responseStatus,
              Reason: "See the details in CloudWatch Log Stream: " + context.logStreamName,
              PhysicalResourceId: physicalResourceId || context.logStreamName,
              StackId: event.StackId,
              RequestId: event.RequestId,
              LogicalResourceId: event.LogicalResourceId,
              Data: responseData
    });

    // eslint-disable-next-line
    console.log("Response body:\n", responseBody);

    var https = require("https");
    var url = require("url");

    var parsedUrl = url.parse(event.ResponseURL);
    var options = {
              hostname: parsedUrl.hostname,
              port: 443,
              path: parsedUrl.path,
              method: "PUT",
              headers: {
      "content-type": "",
      "content-length": responseBody.length
              }
    };

    var request = https.request(options, function(response) {
              // eslint-disable-next-line no-console
              console.log("Status code: " + response.statusCode);
              // eslint-disable-next-line no-console
              console.log("Status message: " + response.statusMessage);
              resolve(context.done());
    });

    request.on("error", function(error) {
              // eslint-disable-next-line no-console
              console.log("send(..) failed executing https.request(..): " + error);
              reject(context.done(error));
    });

    request.write(responseBody);
    request.end();
  })

}