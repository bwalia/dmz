# DMZ

Welcome to DMZ the home of HD API Gateway and HD PoP.

Note: This is technical documentation focusing on the technology and internal workings of the DMZ API Gateway. For Sciensano DMZ Business Documentation please refer to `https://docs.healthdata.be/documentation/dc-devops-internal/dmz`

What is HD API Gateway and HD PoP (Point of Presence)?

DMZ is a nginx based custom build Web Security layer 7 application appliance or you can call it a HTTP(s) traffic manaager or even a Web firewall. The idea of the openresty custom API GW firewall is that the entire traffic HTTP(S) Requests are passed through this application for all Sciensano services online. So the HTTP Traffic manager and router build into this DMZ can be manipulated using OPS API and security rules can be set to manage the security of the APIs and other endpoints. It can be often referred as HD PoP 'Point of Presence' offering API Gateway and Caching layer similar to a typical CDN and a Web appliance in enterprises, and it is fully pluggable solution via integration API called OPSAPI.

HD PoP can be fully configured automatically via pipelines via Ansible roles without any downtimes and without reloading nginx cluster(s) and HD PoP encourages proper release mangement system processes and follow the deployment best practices and OPS API is immutable and has version controlled build into it for true micro services architecture.

Albeit there is some Work in progress but the plan is once a version of an API is released it is locked and if anything changes we provide new version number to access changed OPS API objects which gives reliability and ability to roll back of the configuration.

## Environments 

DMZ at HD side is deployed in three environments

- Dev/Test

Note: The API GW Test env is Publically available but protected at layer 7 by network and IP level limited access to VPN network only.

Dev / Testing is done on Balinder's laptop for now. Setup Dev environment on your local or do docker run to be able to make changes in the API GW

- Acc

Note: The API GW Acc env is Publically available but protected at layer 7 by network and IP level limited access to VPN network only.

[API GW Acc env OPS API] https://dmz.dev.kubes.healthdata.be/
[API GW Acc env FrontDoor] https://frontdoor-acc.kubes.healthdata.be/


- Prod

Note: The API GW Prod env is NOT Publically available & protected at layer 7 by network and IP level limited access to VPN network only as well as NetScaler level.

[API GW Acc env OPS API] https://dmz.kubes.healthdata.be/
[API GW Acc env FrontDoor] https://frontdoor-test.kubes.healthdata.be/


## A typical implementation of HD API Gateway and the HD PoP is shown in the illustration below.HD PoP stands for Point of Presence & it acts as a frontdoor traffic manager and it is build on top of the famous Nginx Openresty Framework. The complete working illustation can help you to understand the purpose of dmz.

![image](https://github.com/Sciensano-Healthdata/dmz/blob/75de798e962a22dc35ee6154fffdc89fc92a21d0/images/hd-api-gw-openresty-pop-v1.png)

## A complete technical Workflow below illustrating how this entire API GW Solution works?

At HD side the storage mode destination is set to Redis as REC (Redis enterprise cluster is running in HA in Kubernetes isolating business logic and the securirty rules from the application itself). At DP side storage mode destination is set to Disk (So the security rules are defined in the JSON files as one off installation step or in the Version control system such as github and then deployed via Ansible pipeline). But the solution is flexible and can be setup in push and pull environments for airgapped environments.

![image](https://github.com/Sciensano-Healthdata/dmz/blob/7d7f2cef297bef114dad232ab9df83521a4434e2/images/api-gateway-cdn-workflow.drawio.png)

## HD Side Workflow 

At HD side the storage mode destination is set to Redis as REC (Redis enterprise cluster is running in HA in Kubernetes isolating business logic and the securirty rules from the application itself)
![image](https://github.com/Sciensano-Healthdata/dmz/blob/e1f238e54a57936d24e6b8b874e0b65488fe0ccd/images/sciensano-api-gw-dps-side.png)

## DP Side Workflow 

At DP side storage mode destination is set to Disk (So the security rules are defined in the JSON files as one off installation step or in the Version control system such as github and then deployed via Ansible pipeline)

![image](https://github.com/Sciensano-Healthdata/dmz/blob/e1f238e54a57936d24e6b8b874e0b65488fe0ccd/images/sciensano-api-gw-dps-side.png)


## Dev Rquirements

1. Docker container to run DMZ we use official openresty base fat alpine image and build private image with additional configuration and save in Healthdata private Nexus repository securely.

2. Redis container to store and manage API GW security rules and TLS certs etc. (Redis cluster makes HD API Gateway PoP a true HA environment especially at HD side)

3. OPS API container (A fully comprehensive API to manage Nginx path based security, IP to Country integration to configure firewall rules based on country of the user, Open ID Connect JWT Token Auth. fully configurable for each Origin to protect data APIs)

![image](https://github.com/Sciensano-Healthdata/dmz/blob/45b85d8d8588c7aa33ade9d3c4e9dc22d5e7cffd/images/hd-api-gw-hd-pop-drawio.png)

DMZ consists of three main components

1. HD API GW OPSAPI (Also referred as Control Plane - Redis runs in Kubernetes HA env)
2. HD PoP - Point of Presence (Front door gateway service)
3. React Admin UI (Optional for dev and testing Security rules, typically runs in Kubernetes HA env)
## Additional React admin U

React Admin dependent on Node and can run additional container to manage API GW Redis config via Admin Dashboard UI. This UI probably won't be needed 

node > 16

yarn

## Installation

## To install dmz api gw and front door services in kubernetes 

```...for OPS API service```

`helm upgrade -i hd-front-gw-test ./devops/helm-charts/dmz -f devops/helm-charts/dmz/values-test-front-k3s1.yaml --set TARGET_ENV=test --namespace test --create-namespace`

```...for front door service```

`helm upgrade -i hd-front-gw-test ./devops/helm-charts/dmz -f devops/helm-charts/dmz/values-test-front-k3s1.yaml --set TARGET_ENV=test --namespace test --create-namespace`

## For non kubernetes installation and docker please refer to the commands below.

```bash
cd openresty-alpine

# install the libraries
yarn install

# create the build
yarn build

# Run the docker
docker compose --env-file .env.dev up -d --build
```
## Storage of the HD PoP and API Gateway Security Rules.

At HD side set storage mode destination to Redis as REC (Redis enterprise cluster is running in HA in Kubernetes isolating business securirty rules from application)

![image](https://github.com/Sciensano-Healthdata/dmz/blob/d65e89b92c23736909ab21dc8a85c279d0f90017/images/hd-pop-save-config-ha-redis-in-case-of-hd-or-disk-in-case-of-dp.png)

## Dashboard API UI

HD API Gateway (Optionally) can be configured to setup Virtual hosts and attach security rules to API GW via easy to use Admin Dashboard which is secure.

In non production env API smoke testing can be easily done via UI and can act as a play ground to test security rules. It can also assist OPS team to setup and test security rules quickly and easily before making final robust API calls for production as immutable configuration.

`Setting up nginx virtual host via OPSAPI or Dashboard Admin UI`

![image](https://github.com/Sciensano-Healthdata/dmz/blob/d65e89b92c23736909ab21dc8a85c279d0f90017/images/hd-pop-create-virtual-host.png)

## Usage

If you want to change anything in the react-admin to change openresty admin dashboard for maintain security rules then you need to run the 
```
yarn build
```
on your local system. It will automatically sync the build changes with the docker compose in place. See docker-compose.yaml

## HD PoP allows Ops to set maintenance and customised error pages via OPS API without reloading nginx
```
Example default page can be set via API or Admin dashboard (Make sure to encode HTML and images into base64 before setting up these pages)
```

![image](https://github.com/Sciensano-Healthdata/dmz/blob/d65e89b92c23736909ab21dc8a85c279d0f90017/images/hd-pop-default-page-setup-example.png)

## OPS API

HD PoP API Gateway can be configured to allow and or disallow access to certain resources based on the uri path, IP or the country of the client web browser networks and or OpenID connect JWT token validation. OWASP Top 10 security firewall to come soon [DDoS mitigation, Rate limiting, Fail2Ban, TLS cert automation via LetsEncrypt or HC Vault Integration, SQL injection and XSS attack mitigation, Session hijack mitigation, CORS and HSTS response header setup, AB testing, HTTP Traffic diversion based on User language and location profiles, better error handling for backend resources ,Global Cache and SSO token validation for all origin apps and fine grained control over user roles and permissions in the token payload ]

![image](https://github.com/Sciensano-Healthdata/dmz/blob/d65e89b92c23736909ab21dc8a85c279d0f90017/images/hd-pop-api-gw-rule-example-allow-api-from-belgium-only.png)

and much more...


## OPS API Examples

## Profiles

### Profile is like an environment or a way of categorising the resoruce in the nginx server or route rule.

```
curl -X 'GET' \
  'https://dmz.kubes.healthdata.be/api/profiles?pagination[page]=1&pagination[perPage]=10&sort[field]=id&sort[order]=ASC&filter[profile_id]=prod' \
  -H 'accept: */*' \
  -H 'Authorization: Bearer <JWT_TOKEN>'
```
### Above call should respond with a list of profiles available in this instance

### To fetch list of all the servers run:

```
user@VM ~ % curl -g -X 'GET' \
  'https://dmz.kubes.healthdata.be/api/servers?pagination[page]=1&pagination[perPage]=10&sort[field]=id&sort[order]=ASC&filter[profile_id]=prod' \
  -H 'accept: */*' \
  -H 'Authorization: Bearer <JWT_TOKEN>' | jq .

```
### To fetch list of all the rules run:

```
user@VM ~ % curl -g -X 'GET' \
  'https://dmz.kubes.healthdata.be/api/rules?pagination[page]=1&pagination[perPage]=10&sort[field]=id&sort[order]=ASC&filter[profile_id]=prod' \
  -H 'accept: */*' \
  -H 'Authorization: Bearer <JWT_TOKEN>' | jq .
```

## To create a new rule try:
```
user@VM ~ % curl -X 'POST' \
  'https://dmz.kubes.healthdata.be/api/rules' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer <JWT_TOKEN>' \
  -H 'Content-Type: application/json' \
  -d '{
  "name": "Rule_Name",
  "profile_id": "test",
  "version": 1,
  "priority": 1,
  "match": {
    "rules": {
      "path_key": "starts_with",
      "path": "/api",
      "country_key": "equals",
      "country": "BE",
      "client_ip_key": "equals",
      "client_ip": " 172.18.0.1",
      "jwt_token_validation": "equals",
      "jwt_token_validation_value": "Authorization",
      "jwt_token_validation_key": "<JWT_TOKEN>"
    }
  },
  "response": {
    "allow": false,
    "code": 403,
    "message": "SGVsbG8gd29ybGQh"
  }
}'
```
### Response:

```
{"data":{"match":{"rules":{"path":"\/api","country":"BE","client_ip":" 172.18.0.1","client_ip_key":"equals","jwt_token_validation":"equals","country_key":"equals","path_key":"starts_with","jwt_token_validation_value":"Authorization","jwt_token_validation_key":"PEpXVF9UT0tFTj4="}},"id":"23023e18-52d2-9b5e-a609-5d34db9a1957","response":{"message":"SGVsbG8gd29ybGQh","code":403,"allow":false},"version":1,"created_at":1733479547,"priority":1,"name":"Rule_Name","profile_id":"test"}}
```

## Create a new server object (Copy Rule uuid from previous calls when creating a rule)

### 

```
curl -X 'POST' \
  'https://dmz.kubes.healthdata.be/api/servers' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer ' \
  -H 'Content-Type: application/json' \
  -d '{
  "server_name": "localhost",
  "profile_id": "test",
  "root": "/var/www/html",
  "rules": "f8107018-2979-4c16-cd61-ab8a8b3303b1 (Rule uuid)",
  "index": "index.html",
  "locations": {
    "location_path": "/api",
    "location_opts": [
      "allow",
      "try_files"
    ],
    "location_vals": {
      "allow": "127.0.0.1",
      "try_files": "html"
    }
  },
  "access_log": "logs/access.log",
  "error_log": "logs/error.log",
  "match_cases": [
    {
      "statement": "a0b5fe52-2fdc-cf47-2b82-f3c69ee39ae2 (Rule uuid)",
      "condition": "and"
    }
  ],
  "listens": [
    {
      "listen": "8080"
    }
  ],
  "created_at": 1687334596,
  "custom_block": [
    {
      "additional_block": "include /tmp/resolver.conf;"
    }
  ],
  "config": "server {\n        listen 8080;  # Listen on port (HTTP)\n        server_name localhost;  # Your domain name\n        root /var/www/html;  # Document root directory\n        index index.html;  # Default index files\n        access_log /logs/access.log;  # Access log file location\n        error_log /logs/error.log;  # Error log file location\n\n        location /api {\n                  allow 127.0.0.1\ntry_files html\n                  }\n        include resolver.conf;\n    }\n    ",
  "config_status": false
}'
```

## Postman collections and export and import feature to manage servers and rules in bulk.

See postman examples to export and import postman collections and checkout the API Swagger page to manage server hosts in Nginx and attach security rules for each virtual host without reloading nginx.

[Click here to visit DMZ Swagger API reference guide] https://dmz.dev.kubes.healthdata.be/swagger/

Note: For Sciensano DMZ Business Documentation please refer to `https://docs.healthdata.be/documentation/dc-devops-internal/dmz`
# dmz
