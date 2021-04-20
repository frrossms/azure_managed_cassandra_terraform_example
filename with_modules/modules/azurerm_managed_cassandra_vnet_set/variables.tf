variable "layout" {
    type = map(object({
        location = string
        cidr = string
    }))
}

variable "resource_group_name" {
    type = string
}

variable "name_format" {
    type = string
    default = "cassandra-%s-vnet"
}