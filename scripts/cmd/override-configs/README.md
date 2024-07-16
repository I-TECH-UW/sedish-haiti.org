# Override configs

A go script that should run in the Dockerfile of this image to override implementation configs and packages in the platform

## Use

Declare an overrides array in your package-metadata.json file to only copy over the stipulated files or leave out to copy everything in the package directory

## Build

Run:
`GOOS=linux GOARCH=amd64 go build`
