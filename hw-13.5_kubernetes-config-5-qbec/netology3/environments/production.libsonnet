
// this file has the param overrides for the stage environment
local production = import './stage.libsonnet';

production {
  components +: {
    backend +: {
      replicas: 3,
    },
    frontend +: {
      replicas: 3,
    },
    db +: {
      replicas: 3,
    },
    endpoint: {
      address: "213.180.193.58"
    }
  }
}
