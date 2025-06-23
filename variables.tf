variable "region" {
  description = "The AWS region to deploy the vpc endpoint"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_id" {
  description = "The ID of the VPC in which the endpoint will be used"
  type        = string
}

variable "vpc_endpoint_name" {
  description = "The name of the VPC Endpoint resource - try and match the service name as close as possible"
  type        = string
}

variable "service_name" {
  description = "The service name. For AWS services the service name is usually in the form com.amazonaws.<region>.<service>"
  type        = string
}

variable "security_group_ids" {
  description = "The ID of one or more security groups to associate with the network interface. Applicable for endpoints of type Interface. If no security groups are specified, the VPC's default security group is associated with the endpoint."
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "The ID of one or more subnets in which to create a network interface for the endpoint."
  type        = list(string)
  default     = []
}

variable "managed_private_dns_enabled" {
  description = "Whether or not to associate a AWS managed private hosted zone with the specified VPC - AWS services and AWS Marketplace partner services only"
  type        = bool
  default     = false
}

variable "custom_private_r53_zone" {
  description = "If desired specify a private dns hosted zone for the VPC endpoint"
  type        = string
  default     = ""
}

variable "custom_private_r53_zone_ttl" {
  description = "If desired specify the ttl of the dns record for the VPC endpoint"
  type        = string
  default     = "300"
}

variable "custom_private_r53_associated_vpcs" {
  description = "A list of additional VPC IDs that's to be associated with the custom Route53 PHZ"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "sg_description" {
  description = "Description of security group"
  type        = string
  default     = "${var.vpc_endpoint_name}-sg"
}

variable "sg_ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    ip_protocol = string
    cidr_ipv4   = string
  }))
  default = []
}

variable "sg_egress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    ip_protocol = string
    cidr_ipv4   = string
  }))
  default = []
}


