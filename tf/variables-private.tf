variable "compartment_id" {
  type        = string
  description = "The compartment to create the resources in"
  default     = "ocid1.tenancy.oc1..aaaaaaaakqbx4b5npvrfpprq2jd3c52zpwa6riptpnuk3hluk2tx6f3q43ma"
}
variable "region" {
  type        = string
  description = "The region to provision the resources in"
  default     = "eu-frankfurt-1"
}
variable "ssh_public_key" {
  type        = string
  description = "The SSH public key to use for connecting to the worker nodes"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDuVSIT4142r4OwNK9R82Li+l0UwIPCRjOCN2jW1f5SPb9/lqMnPjF+vNC/cIGtxVidfGYN35/BCqiiVAj0rUyCMo7BEU6EPcHm6D+NrK1ev46PCb6NUJuC7OzxGeYGAWr8FtXF66SfegmOyUcogW7fksPc+HRmADvm/J1gH8hfHHe4/l1NpgVK51ytCyCBm53yFM53+RcFpCZrhcZt0S2k47FLg/vzKhUWw2uSiGEoKH3c8+3hUuHuaqBBv5GpASijjA9KuhJTYjF9YV5WfBz7bB6VjEu+lJXPeacMl0ZymHjpN9UuEC9LywVdHQuE3rH6YapUSw53bb0IanbdC+UnkmukAA/R2A/UXIkl9U8za651qgFQY9fVpPVjRqzLWZYkQGG8gSpDBGJIRHwVZpqstKmfszIBl2YkthGqH7MYuTVOrDUhNEpppprT0rtaBPA8dq2LJ0Kkx5ILbjQ+1pKAoeIz+Ojkx1yAUVVIJFgDpkl1E8GOk9j8ovmQVCl1cbM5F6YaT556Ftd4lOdFe+XtPHz6NhPXUtKSzUQB9vyGN1k6ptqFTgBi50/ukUIy21BpBNrpoAabcgoqV/9oDJmWEac9bKMaioZOdcN2RHaoMzRQl0jCKP2m6UdbBAVreuAVKDg5ELTMST+6zMx/QstOKtpDphwI0CjSE/TEF8yZvw== piontec@T495"
}
variable "bastion_allowed_ips" {
  type        = list(string)
  description = "List of IP prefixes allowed to connect via bastion"
  default     = ["127.0.0.1/32"]
}
variable "ad_list" {
  type        = list(any)
  description = "List of length 2 with the names of availability regions to use"
  default     = ["fJnH:EU-FRANKFURT-1-AD-1", "fJnH:EU-FRANKFURT-1-AD-1"]
}
