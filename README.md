# NGINX App Protect Tools

This repo is a quickstart for using the [App Protect converter tools](https://docs.nginx.com/nginx-app-protect-waf/v4/configuration-guide/configuration/#converter-tools) released in v2.3 in your CI/CD pipeline. The tool examples use Ubuntu in a Docker container to highlight that these tools can be used in a fast, yet ephemeral manner.

The available tools are:

- **Policy Converter** -
Converts XML format ASM/AWAF security policy to App Protect JSON declarative format.

- **Signature Report Tool** -
Exports signature metadata of the signatures installed on a system.

- **User-defined Signatures Converter** -
Converts ASM/AWAF user-defined signatures to App Protect JSON format. While the Docker container in this repo can potentially be used to convert user-defined signatures, the scripts have not been implemented to do so at this time.

## Dependencies

The examples below require [Docker](https://www.docker.com/) and [jq](https://stedolan.github.io/jq/) to be installed on the host to function properly.

## App Protect Tool Instructions

Copy your NGINX repo Certificate and Key files to the `license` directory.

Then, build the tools container:

``` shell
DOCKER_BUILDKIT=1 docker build --platform linux/amd64 --no-cache --secret id=nginx-crt,src=license/nginx-repo.crt --secret id=nginx-key,src=license/nginx-repo.key -t app-protect-tools .
```

**NOTE:** If you need to change the signature package to be reported on, you must alter the Dockerfile to install the desired signature package, then rebuild the container before running the signature port commands.

### Policy Converter Tool

Run the policy converter and save `nap_policy.json` and `nap_policy.yaml` files to local `tmp` directory:

```shell
docker run --platform linux/amd64 -v $(pwd)/tmp:/tmp --entrypoint "sh" app-protect-tools convert.sh
```

### Signature Report Tool

Run the signature report tool against the signatures installed when the container was built:

```shell
docker run --platform linux/amd64 -v $(pwd)/tmp:/tmp --entrypoint "sh" app-protect-tools signature-report.sh
```

Get the revision date of the signature package:

```shell
 cat tmp/signature-report.json | jq '.revisionDatetime'
```

Check which signatures are linked to CVEs:

```shell
cat tmp/signature-report.json | jq '.signatures[] | select(.hasCve==true)'
```

Or, get the count of the above"

```shell
cat tmp/signature-report.json | jq '[.signatures[] | select(.hasCve==true)] | length'
```

Get the count of all app Denial of Service type signatures"

```shell
cat tmp/signature-report.json | jq '[.signatures[] | select(.attackType.name=="Denial of Service")] | length'
```

Find a specific signature by ID:

```shell
cat tmp/signature-report.json | jq '.signatures[] | select(.signatureId==200000018)'
```

From the signature list, generate and export 50 signature override policy fragments per URL

```shell
cat tmp/signature-report.json | jq '[.signatures[] | select(.hasCve==true)] | .[0:50] | to_entries | map({ "method": "*", "name": ("/test" + (.value.signatureId | tostring) + "*"), "protocol": "http", "type": "wildcard", "wildcardOrder": (.key+1), "signatureOverrides": [ { "enabled": false, "signatureId": .value.signatureId }]})'
```

### Validating a Policy Against the App Protect Schema

This is an example as to how you can use the [Ajv Validator CLI](https://github.com/ajv-validator/ajv-cli) to validate a JSON policy file against the NGINX App Protect [JSON schema](https://json-schema.org/).
NOTE: This example does not use the Docker container above.

1. Export the JSON schema from App Protect using the instructions [here](https://docs.nginx.com/nginx-app-protect/configuration/#policy-configuration-overview). Though it is best to export the schema from the version of App Protect that is installed, you may optionally use a copy of the schema file as of App Protect 3.6 is included in the root of this repo.

1. Install [Node.js](https://nodejs.org/en/)

1. Install the `ajv-cli` validator npm package globally:

    ```shell
    npm install -g ajv-cli
    ```

1. Install the `ajv-formats` npm package globally:

    ```shell
    npm install ajv-formats -g
    ```

1. Perform the policy validation:

    ```shell
    ajv validate -d <path to json policy>  -s <path to json schema> -c ajv-formats
    ```
