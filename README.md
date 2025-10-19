# SSH Termux Notify - Script PAM

## Description

Ce projet permet d'envoyer une notification sur un smartphone Android (via Termux) à chaque ouverture de session SSH sur un serveur Linux.
L'intégration se fait via PAM (Pluggable Authentication Modules), de sorte qu'à chaque connexion SSH, un script est automatiquement exécuté et envoie une notification locale sur le téléphone.

## Fonctionnement

Lorsqu'un utilisateur ouvre (ou ferme) une session SSH, PAM appelle automatiquement le script /usr/local/sbin/notify-termux.sh.

Ce script récupère les variables d'environnement fournies par PAM :
- PAM_USER : nom d'utilisateur
- PAM_RHOST : adresse IP distante
- PAM_TTY : terminal associé
- hostname : nom d'hôte du serveur
- date : horodatage ISO 8601

Ensuite, il envoie, via une commande SSH sans interaction, une requête vers l’application Termux sur un smartphone Android. Le téléphone affiche alors une notification locale contenant ces informations.

## Configuration côté téléphone (Termux)

Installer Termux et les paquets nécessaires :

pkg install openssh termux-api

Lancer le serveur SSH sur Termux :

sshd -p 8022

Ajouter la clé publique du serveur sur le téléphone :

ssh-copy-id -i /root/.ssh/termux_notify_key.pub -p 8022 termux@<IP_TEL>

Remplacer <IP_TEL> par l'adresse IP du téléphone.

## Configuration côté serveur

Créer la clé SSH dédiée :

sudo ssh-keygen -t ed25519 -f /root/.ssh/termux_notify_key

Placer le script PAM :

sudo cp notify-termux.sh /usr/local/sbin/notify-termux.sh
sudo chmod 700 /usr/local/sbin/notify-termux.sh

Exemple minimal de script notify-termux.sh :

## Journalisation

Le script écrit les événements dans /var/log/notify-termux.log. Ce fichier n'est pas inclus dans le dépôt GitHub. à créer manuellement si besoin.


## Notes

- Le script est appelé à chaque événement PAM (connexion et fermeture). J'ai filtré pour que ce soit qu'à l'ouverture avec une nouvelle variable PAM_TYPE.
- L'accès SSH entre le serveur et le téléphone doit être sans mot de passe.
- PAM exécute le script avec des privilèges root
