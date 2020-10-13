const express = require("express");
const router = express.Router();
const URI = require('urijs');
const async = require('async');
const fhirWrapper = require('../fhir')();
const logger = require('../winston');
const config = require('../config');

router.get('/:location?/:lastUpdated?', (req, res) => {
  const location = req.params.location;
  const lastUpdated = req.params.lastUpdated;
  
  logger.info('Received a request for an ISP with location a bundle of resources');
});

router.get('/Patient/:id/:lastUpdated?', (req, res) => {
  const id = req.params.id;
  const lastUpdated = req.params.lastUpdated;
  
  logger.info('Received a request for an ISP with location a bundle of resources');
});


module.exports = router;