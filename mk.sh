./build-image.sh

#./instant project down --env-file .env
#./instant project destroy --env-file .env
#./instant project init --env-file .env

# ./instant package remove -n interoperability-layer-openhim --env-file .env
# ./instant package init -n interoperability-layer-openhim --env-file .env

# ./instant package remove -n emr-isanteplus --env-file .env
# ./instant package init -n emr-isanteplus --env-file .env
./instant package remove -n document-data-store-xds --env-file .env
./instant package init -n document-data-store-xds --env-file .env

#./instant package remove -n shared-health-record-openshr --env-file .env
#./instant package init -n shared-health-record-openshr --env-file .env

#./instant package remove -n openhim-mediator-openxds --env-file .env
#./instant package init -n openhim-mediator-openxds --env-file .env

# ./instant package remove -n client-registry-opencr --env-file .env
# ./instant package init -n client-registry-opencr --env-file .env


# ./instant package remove -n data-pipeline-isanteplus --env-file .env
# ./instant package init -n data-pipeline-isanteplus --env-file .env

#./instant package remove -n monitoring --env-file .env
#./instant package init -n monitoring --env-file .env



# ./instant package remove -n fhir-datastore-hapi-fhir --env-file .env
# ./instant package init -n fhir-datastore-hapi-fhir --env-file .env

# ./instant package remove -n shared-health-record-fhir --env-file .env
# ./instant package init -n shared-health-record-fhir --env-file .env



# ./instant package remove -n data-pipeline-isanteplus --env-file .env
#./instant package init -n data-pipeline-isanteplus --env-file .env


# ./instant package remove -n reverse-proxy-nginx --env-file .env
# ./instant package init -n reverse-proxy-nginx --env-file .env