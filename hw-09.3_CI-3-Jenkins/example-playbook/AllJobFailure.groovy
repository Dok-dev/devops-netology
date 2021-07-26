// scan all jobs and find once failed

Jenkins.instance.getAllItems(Job.class).each{ job ->
  job.builds.each { build ->
    if (build.result == Result.FAILURE) { 
      println job.name + " - " + job.class
    }
  }
}
