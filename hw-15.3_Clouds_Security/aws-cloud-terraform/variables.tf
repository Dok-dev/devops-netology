variable "region" {
  description = "The region where to deploy this code."
  default     = "eu-central-1"
}

variable "expiration_days" {
  description = "Number of days after which to expunge the objects"
  default     = "1"
}