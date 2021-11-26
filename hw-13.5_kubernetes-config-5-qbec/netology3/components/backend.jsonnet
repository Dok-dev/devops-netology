local p = import '../params.libsonnet';
local params = p.components.backend;


[
  {
    "apiVersion": "apps/v1",
    "kind": "Deployment",
    "metadata": {
      "name": params.name
    },
    "spec": {
      "selector": {
         "matchLabels": {
            "app": params.name
         }
      },
      "replicas": params.replicas,
      "template": {
        "metadata": {
          "labels": {
            "app": params.name
          }
        },
        "spec": {
          "containers": [
            {
               "image": params.image,
               "imagePullPolicy": "IfNotPresent",
               "name": params.name,
               "ports": [
                 {
                    "containerPort": params.ports.containerPort,
                    "protocol": "TCP"
                 }
               ],
               "env": [
                  {
                     "name": "DATABASE_URL",
                     "value": "postgres://postgres:postgres@" + p.components.db.name + ":" + p.components.db.service.port + "/news"
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
            "targetPort": params.ports.containerPort
        }
      ]
    }
  }
]