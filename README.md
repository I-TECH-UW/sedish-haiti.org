# Shared Health Record
Proof of Concept Environment

## Components
### OpenCR

### iSantePlus EMR
- https://github.com/pmanko/isanteplus-docker/tree/shr

### OpenMRS EMR
- https://github.com/pmanko/docker-openmrs-server

### Local HAPI JPA Server
- https://hub.docker.com/r/bhits/hapi-fhir-jpaserver/

### OpenHIM
- http://openhim.org/docs/installation/docker

### SHR HAPI JPA Server
- https://hub.docker.com/_/postgres
- https://github.com/hapifhir/hapi-fhir-jpaserver-starter#deploy-with-docker-compose

### Flink & Pipeline
- https://ci.apache.org/projects/flink/flink-docs-stable/ops/deployment/docker.html
- https://github.com/pmanko/beam-local-sync

## Installation
1. Install Docker

2. Clone the repository

3. Download https://www.dropbox.com/s/qp8zvaefuivqpcb/openmrs.zip?dl=1 and unzip into project directory

4. Use docker-compose to build and start containers

5. Clone local sync pipeline code

