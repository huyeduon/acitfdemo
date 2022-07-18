#!/bin/bash
terraform plan -out main.terraform
terraform apply -auto-approve 