./build-image.sh

#./instant project down --env-file .env
#./instant project destroy --env-file .env
#./instant project init --env-file .env

#nfs
#./instant package remove -n nfs --env-file .env
#./instant package init -n nfs --env-file .env
#./instant package down -n nfs --env-file .env
#./instant package up -n nfs --env-file .env


#reverse proxy
#./instant package remove -n reverse-proxy-nginx --env-file .env
#./instant package init -n reverse-proxy-nginx --env-file .env
#./instant package down -n reverse-proxy-nginx --env-file .env
#./instant package up -n reverse-proxy-nginx --env-file .env

#openhim

#./instant package remove -n interoperability-layer-openhim --env-file .env
#./instant package init -n interoperability-layer-openhim --env-file .env
#./instant package down -n interoperability-layer-openhim --env-file .env
#./instant package up -n interoperability-layer-openhim --env-file .env

#isanteplus

# ./instant package remove -n emr-isanteplus --env-file .env
#./instant package init -n emr-isanteplus --env-file .env
#./instant package down -n emr-isanteplus --env-file .env
#./instant package up -n emr-isanteplus --env-file .env

#opencr
# ./instant package remove -n client-registry-opencr --env-file .env
# ./instant package init -n client-registry-opencr --env-file #.env
#./instant package down -n client-registry-opencr --env-file .env
#./instant package up -n client-registry-opencr --env-file .env

#monitroing
#./instant package remove -n monitoring --env-file .env
#./instant package init -n monitoring --env-file .env
#./instant package down -n monitoring --env-file .env
#./instant package up -n monitoring --env-file .env

#data pipeline
# ./instant package remove -n data-pipeline-isanteplus --env-file .env
# ./instant package init -n data-pipeline-isanteplus --env-file .env
#./instant package down -n data-pipeline-isanteplus --env-file .env
#./instant package up -n data-pipeline-isanteplus --env-file .env

#document-data-store-xds
#./instant package remove -n document-data-store-xds --env-file .env
#./instant package init -n document-data-store-xds --env-file .env
./instant package down -n document-data-store-xds --env-file .env
./instant package up -n document-data-store-xds --env-file .env

#kafka
#./instant package remove -n message-bus-kafka --env-file .env
#./instant package init -n message-bus-kafka --env-file .env
#./instant package down -n message-bus-kafka --env-file .env
#./instant package up -n message-bus-kafka --env-file .env

#fhir-datastore-hapi-fhir
#./instant package remove -n fhir-datastore-hapi-fhir --env-file .env
#./instant package init -n fhir-datastore-hapi-fhir --env-file .env
#./instant package down -n fhir-datastore-hapi-fhir --env-file .env
#./instant package up -n fhir-datastore-hapi-fhir --env-file .env -d

#shared-health-record-fhir 
# ./instant package init -n shared-health-record-fhir --env-file .env -d
#./instant package remove -n shared-health-record-fhir --env-file .env
#./instant package down -n shared-health-record-fhir --env-file .env
#./instant package up -n shared-health-record-fhir --env-file .env



#openhim-mediator-openxds 
#./instant package remove -n openhim-mediator-openxds --env-file .env
#./instant package init -n openhim-mediator-openxds --env-file .env
./instant package down -n openhim-mediator-openxds --env-file .env
./instant package up -n openhim-mediator-openxds --env-file .env


#shared-health-record-openshr
#./instant package remove -n shared-health-record-openshr --env-file .env
#./instant package init -n shared-health-record-openshr --env-file .env
#./instant package down -n shared-health-record-openshr --env-file .env
#./instant package up -n shared-health-record-openshr --env-file .env









