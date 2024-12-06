# iSantePlus EMR: Facility Package

## Description
This repository contains a packaged setup for iSantePlus EMR depolyment at individual health facilities. The package includes the following components:
- iSantePlus EMR application
- iSantePlus MySQL database
- Local OpenHIM Service

## Installation
This package can be installed either as a standalone, or attached to an existing MySQL database that might be running currently at the facility. The installation process is as follows:

1. Ensure that the prerequisites are met
2. Clone the repository
3. Run repository setup script
4. Run instant v2 initialization command
5. Finalize configuration of the iSantePlus and OpenHIM instances

*Note:We will publish a docker image of this package to enable even quicker deployment and updates in the future. For now, the package requires local docker build capabilities.*

### Prerequisites
- Docker
- Docker Swarm initialized
- Git
  
### Clone the repository
```bash
git clone isanteplus-local
```

### Run repository setup scripts
```bash
cd isanteplus-local
./get-cli.sh linux latest
sudo ./build-custom-images.sh
sudo docker swarm init
```

### Copy and Modify the .env file
```bash
cp .env.local .env
```

Open the .env file and modify the following variables:
- MYSQL_ROOT_PASSWORD
- etc.

### Run instant v2 initialization command
```bash
./instant project init --env-file .env
```

### Finalize configuration of the iSantePlus and OpenHIM instances
link to Scribe: [Scribe]()