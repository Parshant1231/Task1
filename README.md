# 🏗️ Secure 3-Tier AWS Application Stack

> Automated, production-ready infrastructure using Terraform — App servers in private subnets, RDS in fully isolated subnets, across 2 Availability Zones.

---

## 📐 Architecture Diagram

```
                     ┌──────────────────────────────────────────────────────────────┐
                     │                         AWS CLOUD                             │
                     │                     Region: us-east-1                         │
                     │                                                               │
                     │  ┌───────────────────────────────────────────────────────┐   │
                     │  │                   VPC  10.0.0.0/16                    │   │
                     │  │                                                       │   │
  ┌───────────┐      │  │  ╔═══════════════════════════════════════════════╗   │   │
  │           │──────────►  ║        TIER 1 — PUBLIC SUBNETS               ║   │   │
  │ INTERNET  │      │  │  ║  10.0.0.0/20  (AZ-1)  10.0.1.0/20  (AZ-2)  ║   │   │
  │           │◄─────────── ║                                              ║   │   │
  └─────┬─────┘      │  │  ║  ┌──────────────┐   ┌──────────────────┐   ║   │   │
        │            │  │  ║  │   Bastion    │   │  NAT GW   NAT GW │   ║   │   │
        │ SSH :22    │  │  ║  │  (t3.micro)  │   │  (AZ-1)   (AZ-2) │   ║   │   │
        │ your IP    │  │  ║  │  Key Pair    │   │   EIP      EIP   │   ║   │   │
        └────────────────►  ║  └──────┬───────┘   └────────┬─────────┘   ║   │   │
                     │  │  ╚══════════│══════════════════════│════════════╝   │   │
                     │  │             │ SSH :22               │ outbound NAT   │   │
                     │  │             ▼                       ▼                │   │
                     │  │  ╔═══════════════════════════════════════════════╗   │   │
                     │  │  ║        TIER 2 — PRIVATE SUBNETS               ║   │   │
                     │  │  ║  10.0.2.0/20  (AZ-1)  10.0.3.0/20  (AZ-2)  ║   │   │
                     │  │  ║                                               ║   │   │
                     │  │  ║       ┌───────────────────────────────────┐  ║   │   │
                     │  │  ║       │   Auto Scaling Group  (2 – 6)     │  ║   │   │
                     │  │  ║       │   Amazon Linux 2023 • t3.small    │  ║   │   │
                     │  │  ║       │   Apache • PHP • CloudWatch Agent │  ║   │   │
                     │  │  ║       │   IAM Role: SSM + CloudWatch      │  ║   │   │
                     │  │  ║       │   IMDSv2 enforced • EBS encrypted │  ║   │   │
                     │  │  ║       └───────────────────────────────────┘  ║   │   │
                     │  │  ╚═════════════════════╤═════════════════════════╝   │   │
                     │  │                        │  MySQL :3306                │   │
                     │  │                        │  sg-app → sg-rds only       │   │
                     │  │                        ▼                             │   │
                     │  │  ╔═══════════════════════════════════════════════╗   │   │
                     │  │  ║        TIER 3 — ISOLATED SUBNETS              ║   │   │
                     │  │  ║  10.0.4.0/20  (AZ-1)  10.0.5.0/20  (AZ-2)  ║   │   │
                     │  │  ║                                               ║   │   │
                     │  │  ║  ┌─────────────────┐  ┌─────────────────┐   ║   │   │
                     │  │  ║  │  RDS MySQL 8.0  │  │  RDS Standby    │   ║   │   │
                     │  │  ║  │  PRIMARY (AZ-1) │  │  REPLICA (AZ-2) │   ║   │   │
                     │  │  ║  │  Encrypted      │  │  Auto-failover  │   ║   │   │
                     │  │  ║  │  Backups 7 days │  │  Sync repl.     │   ║   │   │
                     │  │  ║  │  Perf. Insights │  │  Multi-AZ HA    │   ║   │   │
                     │  │  ║  └─────────────────┘  └─────────────────┘   ║   │   │
                     │  │  ║   ⚠ No route to NAT — fully air-gapped      ║   │   │
                     │  │  ╚═══════════════════════════════════════════════╝   │   │
                     │  │                                                       │   │
                     │  │  ┄┄ VPC Endpoints (traffic never leaves AWS) ┄┄┄┄┄  │   │
                     │  │     ▸ S3       (Gateway endpoint)                    │   │
                     │  │     ▸ DynamoDB (Gateway endpoint)                    │   │
                     │  └───────────────────────────────────────────────────────┘   │
                     └──────────────────────────────────────────────────────────────┘
```

---

## 🔐 Security Group Rules

```
┌─────────────────┬──────────────────────────────────┬──────────────────┐
│  Security Group │  Inbound                         │  Outbound        │
├─────────────────┼──────────────────────────────────┼──────────────────┤
│  sg-bastion     │  TCP 22  ← operator_cidr only    │  All traffic     │
├─────────────────┼──────────────────────────────────┼──────────────────┤
│  sg-app         │  TCP 443 ← VPC CIDR              │  All traffic     │
│                 │  TCP 80  ← VPC CIDR              │                  │
│                 │  TCP 22  ← sg-bastion only       │                  │
├─────────────────┼──────────────────────────────────┼──────────────────┤
│  sg-rds         │  TCP 3306 ← sg-app only          │  (stateful)      │
└─────────────────┴──────────────────────────────────┴──────────────────┘
```

---

## 📁 Project Structure

```
.
├── main.tf                   # VPC, subnets, IGW, NAT, SGs, ASG, RDS
├── variables.tf              # All input variables
├── outputs.tf                # Bastion IP, RDS endpoint, subnet IDs
├── user_data.sh.tpl          # App server bootstrap script
├── terraform.tfvars.example  # Config template — copy to terraform.tfvars
└── README.md                 # This file
```

---

## 📏 Subnet Layout

| Subnet | CIDR | AZ | Route | Tier |
|---|---|---|---|---|
| public-1 | 10.0.0.0/20 | AZ-1 | → IGW | Public |
| public-2 | 10.0.1.0/20 | AZ-2 | → IGW | Public |
| private-1 | 10.0.2.0/20 | AZ-1 | → NAT GW (AZ-1) | App |
| private-2 | 10.0.3.0/20 | AZ-2 | → NAT GW (AZ-2) | App |
| isolated-1 | 10.0.4.0/20 | AZ-1 | local only | RDS |
| isolated-2 | 10.0.5.0/20 | AZ-2 | local only | RDS |

---

## ⚙️ Prerequisites

- Terraform `>= 1.3.0`
- AWS CLI configured (`aws configure`)
- An EC2 Key Pair already created in the target region
- Your public IP address for bastion SSH access

---

## 🚀 Deployment Steps

```bash
# 1. Copy and fill in your values
cp terraform.tfvars.example terraform.tfvars

# 2. Initialise providers and modules
terraform init

# 3. Preview what will be created
terraform plan

# 4. Deploy  (~12–15 min, mostly RDS Multi-AZ provisioning)
terraform apply
```

---

## 📤 Outputs After Apply

```bash
terraform output
```

| Output | Description |
|---|---|
| `bastion_public_ip` | Public IP of the bastion host |
| `bastion_ssh_command` | Ready-to-paste SSH command |
| `rds_endpoint` | RDS hostname:port |
| `private_subnet_ids` | App-tier subnet IDs |
| `isolated_subnet_ids` | DB-tier subnet IDs |

---

## 🔌 Connecting Through the Bastion

```bash
# SSH to bastion
ssh -i ~/.ssh/<key-pair>.pem ec2-user@<bastion_public_ip>

# From bastion → RDS
mysql -h <rds_hostname> -u admin -p appdb

# Local port-forward so you can use a local MySQL client
ssh -i ~/.ssh/<key-pair>.pem \
    -L 3307:<rds_hostname>:3306 \
    ec2-user@<bastion_public_ip> -N &

mysql -h 127.0.0.1 -P 3307 -u admin -p appdb
```

---

## 🧹 Tear Down

```bash
# Dev
terraform destroy

# Prod — turn off deletion protection first, then destroy
terraform apply -var='environment=dev'
terraform destroy
```

---

## ✅ Production Checklist

- [ ] Store `db_password` in AWS Secrets Manager, reference via data source
- [ ] Add an Application Load Balancer in front of the ASG
- [ ] Enable VPC Flow Logs → S3 for network audit trail
- [ ] Add AWS WAF to the ALB
- [ ] Use S3 + DynamoDB for Terraform remote state and locking
- [ ] Rotate the bastion key pair on a regular schedule