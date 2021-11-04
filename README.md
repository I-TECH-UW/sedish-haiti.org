# sedish-haiti.org Demo Site

Haiti HIE Architecture
# Components

## OpenMRS EMR
### Host URLs
- openmrs-server: http://localhost:8091/openmrs
- openmrs-db: jdbc:mysql://localhost:3308/openmrs
- fhir metadata: http://localhost:8091/openmrs/ws/fhir2/R4/metadata?_format=json

### Links
- https://github.com/pmanko/docker-openmrs-server

### Notes
- Server container requires restart after initial setup for some reason. 
- Ran into issues with DB character set (https://talk.openmrs.org/t/ui-framework-error-while-attempting-to-access-registration-app/8734/6).
  Had to specify characterset and collation in docker setup.
- To create demo patients, you can set the `OMRS_CONFIG_ADD_DEMO_DATA` variable in the `openmrs/refapp/openmrs-server.env` file
  or set the `createDemoPatientsOnNextStartup` global property to the number of patients you want to create and restart the 
  container.

### OpenCR

### iSantePlus EMR
- https://github.com/pmanko/isanteplus-docker/tree/shr


### Local HAPI JPA Server
- https://hub.docker.com/r/bhits/hapi-fhir-jpaserver/

#### Notes
- Ran into issues with setting up Postgres due to DDL error for some table creation - the 
  generated DLL included "blob". WOndering if we can use this script which uses `oid`. Reverting to mysql f
  for now. (solved: dialect set twice ::sigh:: ) 

### OpenHIM
- http://openhim.org/docs/installation/docker

### SHR HAPI JPA Server
- https://hub.docker.com/_/postgres
- https://github.com/hapifhir/hapi-fhir-jpaserver-starter#deploy-with-docker-compose

## Flink & Pipeline

### Host URLs
- flink console: https://localhost:3002

- https://ci.apache.org/projects/flink/flink-docs-stable/ops/deployment/docker.html
- https://github.com/pmanko/beam-local-sync



## Installation
### 1. Install Docker

Docker Engine:
https://docs.docker.com/compose/install/

Docker Compose:
https://docs.docker.com/compose/install/


### 2. Clone the Sedish Repository

```sh
git clone https://github.com/I-TECH-UW/sedish-haiti.org.git
```

### 3.1 Port-based Setup

#### Start up Core Containers
```sh
sudo docker-compose -f docker-compose.ports.yml up -d openhim-core openhim-console mongo-db opencr-es opencr-fhir shr-fhir nginx
```

#### Start up Mediators

```sh
sudo docker-compose -f docker-compose.ports.yml up -d shr opencr
```

#### Start up iSantePlus
```sh
sudo docker-compose -f docker-compose.ports.yml up -d isanteplus
```

#### Validate Setup
Setup a Postman environment and run tests from this workspace: https://www.postman.com/itechuw/workspace/isanteplus-pilot

OR

Run the test script:



### 3.2 Domain-based setup

#### Generate and / or refresh certificates
Modify the configurations in the `docker-compose.yml` file to match server settings.

Then, run the following command:

```sh
sudo docker-compose up certbot
```

The certificates will be generated and provided to the other containers through a shared volume.
### 3. Start up Core Containers

. Use docker-compose to build and start containers

5. Clone local sync pipeline code

