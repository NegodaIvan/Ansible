#  Создаем vpc на hcloud
resource "hcloud_server" "server" {
   name        = "neg-server"
  image       = "ubuntu-18.04"
  server_type = "cx11"
  backups = "true"
 ssh_keys = [ data.hcloud_ssh_key.negoda.id  ] 
 labels = {
        "email": " ****** "
        "specialty": "devops"
      }
}

#resource "hcloud_ssh_key" "negoda" {
#  name = "neg_ssh"
#  public_key = file("/home/negoda/.ssh/id_rsa.pub")
#}

data "hcloud_ssh_key" "negoda" {
  name = "neg_ssh"
}



# AWS  создадим DNS  запись и привяжем к созданной VPC_hcloud

data "aws_route53_zone" "name_zone" {
  name         = " *********************** "
}


resource "aws_route53_record" "neg_record_dns" {
  name            = "negoda.${data.aws_route53_zone.name_zone.name }"
  ttl             = 300
  type            = "A"
  zone_id         = data.aws_route53_zone.name_zone.zone_id

  records = [ hcloud_server.server.ipv4_address ]
}

# Выведем некоторей данные о созданной VPC

output "hcloud_ip_adress_negoda" {
 value = hcloud_server.server.ipv4_address
}

output "aws_route53_record_neg_record_dns" {
 value = aws_route53_record.neg_record_dns.name
}


resource "local_file" "ansible_inventory" {
     content     = "[ansible]\n  ${join ( "\n", formatlist
                  ( "%s ansible_host=%s",
                      hcloud_server.server.*.name,
                      hcloud_server.server.*.ipv4_address
                )
               )}\n\n[ansible:vars]\n  ansible_user=root\n  ansible_ssh_private_key=/home/negoda/.ssh/id_rsa.pub\n"
    filename = "ansible_inventory"
    file_permission = 664
    provisioner "local-exec" {
           command = "ansible-inventory --list -y -i ./ansible_inventory  >> ansible_inventory.yml"
}
}

