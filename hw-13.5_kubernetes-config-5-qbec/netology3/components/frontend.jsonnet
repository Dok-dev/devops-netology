local p = import '../params.libsonnet';
local params = p.components.frontend;

[
  {
    "apiVersion": "apps/v1",
    "kind": "Deployment",
    "metadata": {
      "name": params.name,
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
                     "name": "BASE_URL",
                     "value": "http://" + p.components.backend.name + ":" + p.components.backend.service.port
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
            "name": "web",
            "protocol": "TCP",
            "port": params.service.port,
            "targetPort": params.ports.containerPort
        }
      ]
    }
  }

]