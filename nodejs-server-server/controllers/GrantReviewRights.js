'use strict';

var utils = require('../utils/writer.js');
var Query = require('../service/QueryService');
var users = require('../db/users');

module.exports.GrantReviewRights = function (req, res, next) {
  var username = req.swagger.params['username'].value;
  var xRequestPassword = req.swagger.params['X-request-password'].value;
  var xRequestUseToken = req.swagger.params['X-request-use-token'].value;
  var xRequestToken = req.swagger.params['X-request-token'].value;
  var reviewtoken = req.swagger.params['X-request-reviewtoken'].value;

  //var projectobj  = JSON.parse(projectdata);

  //var validate = require('jsonschema').validate;

  if (xRequestUseToken)
  {
    var clientIP = req.connection.remoteAddress;
    console.log("USING TOKEN AUTH");
    //users.updatetoken("jx",clientIP,expire,function (){console.log("CALLBACK")});
    users.authByToken(xRequestToken, clientIP, function (retu){
      console.log("CALLBACK 2 valid :" + retu);
      if (!retu.valid)
      {
        res.writeHead(401, { "Content-Type": "text/plain" });
        return res.end("Unauthorized");
      }
      else
      {
            console.log('succesfully identified');
            users.addReviewable(retu.username, reviewtoken, function (retz){
            console.log(retz);
            if (retz == "error")
            {
              res.writeHead(400, { "Content-Type": "plain/text" });
              return res.end("Error, invalid or expired review token provided, you also cannot grant yourself review rights for a project you created");
            }
            res.writeHead(200, { "Content-Type": "plain/text" });
            return res.end("Your reviewing rights have been successfully updated for project id: "+retz);
           });
      }
    })
  }
  else
  {
  users.comparepwd(username, xRequestPassword, function (err, result) {
    if (err) 
    {
        res.writeHead(401, { "Content-Type": "text/plain" });
        return res.end("Unauthorized");
		//returnResponse(res, 403, "Username or password invalid");
        //res.send('{"status" : 403, "payload" : "", "message" : "Username or password invalid" }');
      //throw err;
    }
    else {
      console.log('user :' + JSON.stringify(result));
      if (result) {
        console.log('succesfully identified');

            users.addReviewable(username, reviewtoken, function (retz){
            if (retz == "error")
            {
            res.writeHead(400, { "Content-Type": "plain/text" });
            return res.end("Error, invalid or expired review token provided, you also cannot grant yourself review rights for a project you created");
            }
            res.writeHead(200, { "Content-Type": "plain/text" });
            return res.end("Your reviewing rights have been successfully updated for project id: "+retz);
           });
      }
      else
      {
        res.writeHead(401, { "Content-Type": "text/plain" });
        return res.end("Unauthorized");
	  //returnResponse(res, 403, "Username or password invalid");
		//res.send('{"status" : 403, "payload" : "", "message" : "Username or password invalid" }');
      }
    }
  });

 }
};
