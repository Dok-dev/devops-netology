local p = import '../params.libsonnet';
local params = p.components.frontend;
[
  {
     "apiVersion": "v1",
     "kind": "Endpoints",
     "metadata": {
        "name": params.name,
     },
     "subsets": [
        {
           "addresses": [
              {
                 "ip": p.components.endpoint.address
              }
           ],
           "ports": [
              {
                 "port": params.service.port,
                 "name": "web"
              }
           ]
        }
     ]
  }
]