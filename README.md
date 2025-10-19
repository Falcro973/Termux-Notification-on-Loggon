#SSH Termux Notify -script PAM


##Fonctionnement

Lorsqu’un utilisateur ouvre une session SSH, PAM appelle automatiquement le script `/usr/local/sbin/notify-termux.sh`.

Ce script récupère :
- le nom d’utilisateur (`$PAM_USER`),
- l’adresse IP distante (`$PAM_RHOST`),
- le terminal (`$PAM_TTY`),
- le nom d’hôte (`hostname`),
- et un horodatage ISO 8601.

Puis il envoie, via une commande SSH sans interaction, une requête vers l’application Termux sur un smartphone Android.
Le téléphone affiche alors une notif locale contenant ces informations.

## Petits rappels SSHs

Creation de clefs SSHs: 

sudo ssh-keygen -t ed25519 -f /root/.ssh/termux_notify_key


## Sur le téléphone :

Pour la notification j'ai utilisé termux-api, installable uniquement avec F Droid (merci le play store Android de l'avoir enlevé de la liste des applications disponible)

pkg install openssh termux-api
sshd -p 8022 
#(le 8022 est pas défaut)

#Depuis le serveur (rajout de la clef SSH publique sur le téléphone)
ssh-copy-id -i /root/.ssh/termux_notify_key.pub -p 8022 termux@<IP>


#Config PAM
Rajouter la ligne suivante dans "/etc/pam.d/sshd"

session optional pam_exec.so /usr/local/sbin/notify-termux.sh


#Journalisation interne au script :
/var/log/notify-termux.log

