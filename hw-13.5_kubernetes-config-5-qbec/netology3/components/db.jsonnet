local p = import '../params.libsonnet';
local params = p.components.db;

[
  {
     "apiVersion": "apps/v1",
     "kind": "StatefulSet",
     "metadata": {
        "name": params.name
     },
     "spec": {
        "selector": {
           "matchLabels": {
              "app": params.name
           }
        },
        "serviceName": params.name,
        "replicas": params.replicas,
        "template": {
           "metadata": {
              "labels": {
                 "app": params.name
              }
           },
           "spec": {
              "terminationGracePeriodSeconds": 10,
              "containers": [
                 {
                    "name": params.name,
                    "image": params.image,
                    "imagePullPolicy": "IfNotPresent",
                    "ports": [
                       {
                          "containerPort": params.ports.containerPort
                       }
                    ],
                    "env": [
                       {
                          "name": "POSTGRES_PASSWORD",
                          "value": "postgres"
                       },
                       {
                          "name": "POSTGRES_USER",
                          "value": "postgres"
                       },
                       {
                          "name": "POSTGRES_DB",
                          "value": "news"
                       }
                    ]
                 }
              ]
           }
        }
     }
  },
{
   "apiVersion": "v1",
   "kind": "Service",
   "metadata": {
      "name": params.name
   },
   "spec": {
      "selector": {
         "app": params.name
      },
      "ports": [
         {
            "protocol": "TCP",
            "port": params.service.port,
            "targetPort": params.service.port
         }
      ]
   }
}
]