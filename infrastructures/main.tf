module "networking" {
  source            = "./modules/networking"
  
  project_name      = var.project_name
  vpc_cidr          = var.vpc_cidr
  subnet_cidr       = var.subnet_cidr
  availability_zone = var.availability_zone
}

module "security" {
  source       = "./modules/security"
  
  project_name = var.project_name
  vpc_id       = module.networking.vpc_id
  my_ip        = var.my_ip 
}

module "compute" {
  source            = "./modules/compute"
  
  project_name      = var.project_name
  vpc_id            = module.networking.vpc_id
  subnet_id         = module.networking.subnet_id
  security_group_id = module.security.security_group_id
  instance_type     = var.instance_type
}