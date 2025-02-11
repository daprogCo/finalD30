## **Configuration 1**  

```hcl
provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-05134c8ef96964280"
  instance_type = "t2.micro"
}
```

# **Questions :**  
### 1. Que manque-t-il dans cette configuration pour la rendre fonctionnelle ?
- L'absence d'un attribut _subnet_id_ ou _availability_zone_.

### 2. Pourquoi cette erreur est-elle problématique ?
- Si aucun VPC par défaut n'est présent, **Terraform** renverra une erreur car il ne sait pas dans quel sous-réseau placer l'instance.

### 3. Proposez une correction.
```hcl
provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-05134c8ef96964280"
  instance_type = "t2.micro"

  subnet_id = "subnet-0a1b2c3d4e5f67890"  
}

```

---


## **Configuration 2**  

```hcl
variable "ami_id" {
  type    = string
}

resource "aws_instance" "example" {
  ami           = ami_id
  instance_type = "t2.micro"
}
```

# **Questions :**  
### 1. Cette configuration fonctionnera-t-elle ? Pourquoi ?
- Non. Ici, _ami_id_ est une variable, mais elle doit être appelée avec la syntaxe _var.ami_id_.

### 2. Quelle erreur empêche Terraform d'exécuter ce code ?
```pgsql
Error: Unsupported attribute
│   on main.tf line 6, in resource "aws_instance" "example":
│    6:   ami = ami_id
│ 
│ This object has no attribute named "ami_id".
```
- Les variables définies dans un bloc variable doivent être référencées avec _var.<nom_de_variable>_.

### 3. Proposez une correction.  
```hcl
variable "ami_id" {
  type    = string
  default = "ami-05134c8ef96964280" # Valeur par défaut

resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = "t2.micro"
}
```
---


## **Configuration 4**  

```hcl
resource "aws_instance" "example" {
  ami           = "ami-05134c8ef96964280"
  instance_type = "t2.micro"
  key_name      = "demo-key.pem"
}
```

# **Questions :**  
### 1. Quel est le problème avec la clé SSH ? 
- Le paramètre _key_name_ ne doit contenir que le nom de la clé SSH, sans l’extension _.pem_. 

### 2. Pourquoi cette erreur est-elle problématique ? 
- AWS attend le nom de la clé SSH déjà existante dans **EC2 Key Pairs**, et non le fichier _.pem_.

### 3. Comment pouvez-vous corriger cette configuration ?  
```hcl
resource "aws_instance" "example" {
  ami           = "ami-05134c8ef96964280"
  instance_type = "t2.micro"
  key_name      = "demo-key"  # Suppression de ".pem"
}
```
---

