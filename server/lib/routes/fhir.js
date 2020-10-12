const express = require("express");
const router = express.Router();
const URI = require('urijs');
const async = require('async');
const fhirWrapper = require('../fhir')();
const logger = require('../winston');
const config = require('../config');

router.get('/$ips/:location/:lastUpdated', (req, res) => {
  const location = req.params.location;
  const lastUpdated = req.params.lastUpdated;
  
  logger.info('Received a request for an ISP with location a bundle of resources');



});

router.get('/:resource/:id', (req, res) => {  
  getResource({
    req,
    noCaching: true
  }, (resourceData, statusCode) => {
    for (const index in resourceData.link) {
      if (!resourceData.link[index].url) {
        continue;
      }
      const urlArr = resourceData.link[index].url.split('fhir');
      if (urlArr.length === 2) {
        resourceData.link[index].url = '/fhir' + urlArr[1];
      }
    }
    res.status(statusCode).json(resourceData);
  });

});

// Post a bundle of resources
router.post('/', (req, res) => {
  logger.info('Received a request to add a bundle of resources');
  const resource = req.body;
  
  // Verify that bundle
  if (!resource.resourceType ||
    (resource.resourceType && resource.resourceType !== 'Bundle') ||
    !resource.entry || (resource.entry && resource.entry.length === 0)) {
    return res.status(400).json({
      resourceType: "OperationOutcome",
      issue: [{
        severity: "error",
        code: "processing",
        diagnostics: "Invalid bundle submitted"
      }],
      response: {
        status: 400
      }
    });
  }

  // let patients = [];
  // for(let index in resource.entry) {
  //   let entry = resource.entry[index];
  //   if(entry.resource && entry.resource.resourceType === "Patient") {
  //     patients.push(entry);
  //     resource.entry.splice(index, 1);
  //   }
  // }
  async.parallel({
    otherResources: (callback) => {
      if(resource.entry.length === 0) {
        return callback(null, {});
      }
      fhirWrapper.create(resource, (code, err, response, body) => {
        return callback(null, {code, err, response, body});
      });
    }
  }, (err, results) => {
    let code = results.otherResources.code;
 
    if(!code) {
      code = 500;
    }

    return res.status(code).json([results.patients.body, results.patients.body]);
  });
});

// Create resource
router.post('/:resourceType', (req, res) => {
  saveResource(req, res);
});

// Update resource
router.put('/:resourceType/:id', (req, res) => {
  saveResource(req, res);
});


/** Helpers */

function getResource({
  req,
  noCaching
}, callback) {
  const resource = req.params.resource;
  const id = req.params.id;
  let url = URI(config.get('fhirServer:baseURL'));
  logger.info('Received a request to get resource ' + resource + ' with id ' + id);

  if (resource) {
    url = url.segment(resource);
  }
  if (id) {
    url = url.segment(id);
  }
  for (const param in req.query) {
    url.addQuery(param, req.query[param]);
  }
  url = url.toString();
  fhirWrapper.getResource({
    url,
    noCaching
  }, (resourceData, statusCode) => {
    return callback(resourceData, statusCode);
  });
}

function saveResource(req, res) {
  let resource = req.body;
  let resourceType = req.params.resourceType;
  let id = req.params.id;
  if(id && !resource.id) {
    resource.id = id;
  }

  logger.info('Received a request to add resource type ' + resourceType);

  fhirWrapper.create(resource, (code, err, response, body) => {
    return res.status(code).send(body);
  });
}

module.exports = router;