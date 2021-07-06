# les_14

1. On the server where terraform is installed, clone this repository.
2. Go to the parent directory of the repository.
2. Edit the file "/variables.tf", in which specify your credentials (terraform host key pair and ServiceAccount GCP)
3. Run "terraform init" (initialize resources, modules and dependencies)
4. Execute "terraform apply"

After a successful deployment, check the result at the link: http: // <instance_production_external_ip>: 8090 / hello-1.0