# Shared Health Record
Proof of Concept Environment

## Components
### OpenCR

### iSantePlus EMR
https://github.com/pmanko/isanteplus-docker/tree/shr

### OpenMRS EMR
https://github.com/pmanko/docker-openmrs-server

### Local HAPI JPA Server
https://hub.docker.com/r/bhits/hapi-fhir-jpaserver/

### OpenHIM
http://openhim.org/docs/installation/docker

### SHR HAPI JPA Server
https://hub.docker.com/_/postgres
https://github.com/hapifhir/hapi-fhir-jpaserver-starter#deploy-with-docker-compose

### Flink & Pipeline

## Installation
1. Install Docker

2. Clone the repository

3. Use docker-compose to build and start containers

4. Clone local sync pipeline code

5. Schedule local sync task using a Flink Tumbling Window trigger.

