[
local namespace = "production";

local backend_name = "backend";
local backend_port = "9000";
local backend_replicas = 1;
local backend_image = "0dok0/kubernetes-config_backend:latest";

local frontend_name = "frontend";
local frontend_port = "80";
local frontend_replicas = backend_replicas * 2;
local frontend_image = "0dok0/kubernetes-config_frontend:latest";

local db_name = "db";
local db_port = "5432";
local db_replicas = 1;
local db_image = "postgres:13-alpine";

{
  "apiVersion": "apps/v1",
  "kind": "Deployment",
  "metadata": {
    "name": backend_name,
    "namespace": namespace
  },
  "spec": {
    "replicas": backend_replicas,
    "template": {
      "metadata": {
        "labels": {
          "app": backend_name
        }
      },
      "spec": {
        "containers": [
          {
             "image": backend_image,
             "name": backend_name,
             "ports": [
               {
                  "containerPort": backend_port,
                  "protocol": "TCP"
               }
             ],
             "env": [
                {
                   "name": "DATABASE_URL",
                   "value": "postgres://postgres:postgres@" + db_name + ":" + db_port + "/news"
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
    "name": backend_name,
    "namespace": namespace
  },
  "spec": {
    "selector": {
      "app": backend_name
    },
    "ports": [
      {
          "protocol": "TCP",
          "port": backend_port,
          "targetPort": backend_port
      }
    ]
  }
},

{
  "apiVersion": "apps/v1",
  "kind": "Deployment",
  "metadata": {
    "name": frontend_name,
    "namespace": namespace
  },
  "spec": {
    "replicas": frontend_replicas,
    "template": {
      "metadata": {
        "labels": {
          "app": frontend_name
        }
      },
      "spec": {
        "containers": [
          {
             "image": frontend_image,
             "name": frontend_name,
             "ports": [
               {
                  "containerPort": frontend_port,
                  "protocol": "TCP"
               }
             ],
             "env": [
                {
                   "name": "BASE_URL",
                   "value": "http://" + backend_name + ":" + backend_port
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
    "name": frontend_name,
    "namespace": namespace
  },
  "spec": {
    "selector": {
      "app": frontend_name
    },
    "ports": [
      {
          "name": "web",
          "protocol": "TCP",
          "port": frontend_port,
          "targetPort": frontend_port
      }
    ]
  }
},

{
   "apiVersion": "apps/v1",
   "kind": "StatefulSet",
   "metadata": {
      "name": db_name,
      "namespace": namespace
   },
   "spec": {
      "selector": {
         "matchLabels": {
            "app": db_name
         }
      },
      "serviceName": db_name,
      "replicas": db_replicas,
      "template": {
         "metadata": {
            "labels": {
               "app": db_name
            }
         },
         "spec": {
            "terminationGracePeriodSeconds": 10,
            "containers": [
               {
                  "name": db_name,
                  "image": db_image,
                  "ports": [
                     {
                        "containerPort": db_port
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
    "name": db_name,
    "namespace": "production"
  },
  "spec": {
    "selector": {
      "app": db_name
    },
    "ports": [
      {
        "protocol": "TCP",
        "port": db_port,
        "targetPort": db_port
      }
    ]
  }
}

]