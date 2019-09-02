variable "cluster_name" {
    description = "O nome a ser utilizado por todos os recursos do cluster."
    type        = string
}

variable "instance_type" {
    description = "Tipo da instância EC2."
    type        = string
}

variable "min_size" {
    description = "O número mínimo de instâncias EC2 no ASG."
    type        = number
}

variable "max_size" {
    description = "O número máximo de instancias EC2 no ASG."
    type        = number
}

variable "server_port" {
    description = "A porta que o servidor usará para requisições HTTP"
    type        = number
    default     = 8080
}
