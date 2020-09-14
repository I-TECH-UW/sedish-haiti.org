# Synchronization of Clinical Data 

## Streaming Pipeline: iSantePlus <=> SHR (HAPI FHIR Server)

**This approach uses:**
- https://github.com/pmanko/atomfeed/tree/db-url-port-fix
- https://github.com/pmanko/openmrs-module-atomfeed/tree/isanteplus-fixes
- https://github.com/pmanko/openmrs-fhir-analytics/tree/isanteplus-local-sync

### Patient Sync

**Create a Patient**
1. Log into https://isanteplusdemo.com/openmrs
2. Click `Register a Patient`
3. Fill in all of the required patient information and `Confirm` to create the patient.
4. On the patient chart screen, note the `patientId` in the url bar. 

**View Patient in SHR**
1. Wait a minute or so, and navigate to http://18.158.139.243:8092/hapi-fhir-jpaserver
2. Choose `Patient` from the left-hand `Resources` navigation.
3. Check the `Reverse includes` checkbox on the bottom of the screen.
4. Search by `name` OR by `_id` (using the noted uuid from above) 
5. You can also use the following FHIR search request:
    ```
    http://18.158.139.243:8092/hapi-fhir-jpaserver/fhir/Patient?_id=bc8eaa60-025e-41e3-8b51-803047744f50&_revinclude=*&_pretty=true
    ```



