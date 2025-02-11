## **Playbook 1 - Installer Apache**  

```yaml
---
- name: Installer un package sur Ubuntu
  hosts: all
  become: yes
  tasks:
    - name: Installer Apache
      apt:
      name: apache2
      state: present
```

# **Questions :**  
### 1. Quel problème syntaxique pourrait empêcher ce playbook de fonctionner ?
- _name:_ doit être aligné correctement sous _apt_:, sinon Ansible ne pourra pas interpréter correctement la tâche.

### 2. Identifiez les erreurs
- Mauvaise indentation de la directive_ name:_ sous _apt_:
- Absence de _update_cache: yes_ avant l'installation sous _apt_:

### 3. Expliquez pourquoi ces erreurs sont problématiques.
- Une mauvaise indentation entraîne une erreur de parsing et empêche l'exécution du playbook.
- Sans _update_cache: yes_, l’installation d’Apache pourrait échouer si la liste des paquets n’est pas à jour.

### 4. Proposez une correction

```yaml
---
- name: Installer un package sur Ubuntu
  hosts: all
  become: yes
  tasks:
    - name: Mettre à jour la liste des paquets
      apt:
        update_cache: yes

    - name: Installer Apache
      apt:
        name: apache2
        state: present
```

---



## **Playbook 2 - Mettre à jour le système**  

```yaml
---
- name: Mettre à jour le système
  hosts: all
  become: yes
  tasks:
    - name: Mise à jour du système
      yum:
        update_cache: yes
```


# **Questions :**  
### 1. Ce playbook fonctionnera-t-il sur Ubuntu ? Pourquoi ?
- Non. **Ubuntu** utilise apt comme gestionnaire de paquets au lieu de _yum_. 

### 2. Identifiez les erreurs (la distribution d'au moins une machine worker est _ubuntu22.04_)
- Utilisation du module _yum_ sur une machine **Ubuntu**
- _update_cache: yes_ ne met à jour que l'index des paquets mais ne met pas à jour les paquets eux-mêmes.
- Pas de gestion de compatibilité multi-distribution (RedHat vs Ubuntu)

### 3. Expliquez pourquoi ces erreurs sont problématiques.
- Le playbook échouera sur **Ubuntu** puisque _yum_ n'est pas disponible.
- Le système ne sera pas mis à jour correctement.
- Manque de flexibilité pour gérer plusieurs distributions.

### 4. Proposez une correction
```yaml
---
- name: Mettre à jour le système
  hosts: all
  become: yes
  tasks:
    - name: Mettre à jour le cache des paquets sur Ubuntu
      apt:
        update_cache: yes
        upgrade: dist
      when: ansible_facts['os_family'] == "Debian"

    - name: Mettre à jour le cache des paquets sur CentOS/RHEL
      yum:
        name: "*"
        state: latest
      when: ansible_facts['os_family'] == "RedHat"

```
---



## **Playbook 3 - Créer un utilisateur**  
 **Niveau facile**  

```yaml
---
- name: Créer un utilisateur
  hosts: all
  become: yes
  vars:
    user: "deploy"
  tasks:
    - name: Ajouter l'utilisateur
      user:
        name: "{{ utilisateur }}"
        shell: /bin/bash
```

# **Questions :**  
### 1. Ce playbook va-t-il créer l’utilisateur correctement ? Pourquoi ?
- La variable est définie sous le nom _user_ dans _vars_ mais dans la tâche _user_:, on utilise _{{ utilisateur }}_, qui n'existe pas.

### 2. Identifiez les erreurs (la distribution d'au moins une machine worker est_ ubuntu22.04_)
- Par défaut, **Ansible** ne crée pas automatiquement le répertoire _home_, sauf si l’option _create_home: yes_ est spécifiée.
- Pas de vérification de l’existence préalable de l’utilisateur avant l’ajout.

### 3. Expliquez pourquoi ces erreurs sont problématiques.
- Le playbook échouera sur la variable inexistante (utilisateur).
- L’utilisateur pourrait être créé sans dossier home, ce qui peut causer des problèmes si l’utilisateur doit stocker des fichiers ou exécuter des scripts.
- Le playbook ne vérifie pas si l’utilisateur existe déjà.

### 4. Proposez une correction
```yaml
---
- name: Créer un utilisateur
  hosts: all
  become: yes
  vars:
    utilisateur: "deploy"  # Correction du nom de la variable
  tasks:
    - name: Ajouter l'utilisateur
      ansible.builtin.user:
        name: "{{ utilisateur }}"
        shell: /bin/bash
        create_home: yes  # Assure la création du home directory
        state: present    # Assure que l'utilisateur est bien présent
```
---



## **Playbook 4 - Installer Docker**  

```yaml
---
- name: Installer Docker
  hosts: all
  become: yes
  tasks:
    - name: Installer Docker sur Ubuntu et CentOS
      yum:
        name: docker
        state: present
```

#  **Questions :**  
### 1. Ce playbook fonctionnera-t-il sur Ubuntu ? Pourquoi ?
- **Ubuntu** utilise _apt_ comme gestionnaire de paquets, tandis que le playbook utilise _yum_, qui est spécifique aux distributions basées sur **RedHat** (comme CentOS, Rocky Linux, AlmaLinux).

### 2. Existe-t-il une meilleure approche pour gérer plusieurs distributions ?
- O-U-I-!
- **O**n peut utiliser le module _package_, qui est un gestionnaire de paquets abstrait fonctionnant sur plusieurs distributions.
- **U**ne autre approche consiste à utiliser des conditions (when) pour exécuter la bonne commande en fonction du système d’exploitation.
- **I**ntégrer un rôle dédié à l’installation de **Docker**, permettant une meilleure modularité et réutilisabilité du code dans différents playbooks.

### 3. Expliquez pourquoi ces erreurs sont problématiques.
- Le playbook n’est pas portable et ne fonctionnera que sur RedHat/CentOS.
- Manque de flexibilité 

### 4. Proposez une correction
```yaml
---
- name: Installer Docker
  hosts: all
  become: yes
  tasks:
    - name: Détecter le système d'exploitation
      setup:

    - name: Installer Docker sur Ubuntu
      apt:
        name: docker.io
        state: present
        update_cache: yes
      when: ansible_facts['os_family'] == "Debian"

    - name: Installer Docker sur CentOS
      yum:
        name: docker
        state: present
      when: ansible_facts['os_family'] == "RedHat"
---
```
