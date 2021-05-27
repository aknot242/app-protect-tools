# NGINX App Protect Tools
This repo is a quickstart for using the [App Protect converter tools](https://docs.nginx.com/nginx-app-protect/configuration/#converter-tools) released in v2.3 in your CI/CD pipeline. The tool examples use Alpine in a Docker container to highlight that these tools can be used in a fast, yet ephemeral manner.

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
docker build -t app-protect-tools .
```
**NOTE:** If you need to change the signature package to be reported on, you must alter the Dockerfile to install the desired signature package, then rebuild the container before running the signature port commands.

### Policy Converter Tool
Run the policy converter and save `nap_policy.json` and `nap_policy.yaml` files to local `tmp` directory:

```shell
docker run -v $(pwd)/tmp:/tmp --entrypoint "sh" app-protect-tools convert.sh
```

### Signature Report Tool
Run the signature report tool against the signatures installed when the container was built:

```shell
docker run -v $(pwd)/tmp:/tmp --entrypoint "sh" app-protect-tools signature-report.sh
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