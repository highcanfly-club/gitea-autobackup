# Highcanfly Gitea Backup

This Docker container is designed to be used as a backup helper for Highcanfly's Gitea custom Helm chart. It is available at `highcanfly/gitea-backup`.

## Usage

The entrypoint of this Docker container calls a script located at `/scripts/autobackup.sh`. This script is not provided in the Docker image and should be supplied via a Kubernetes ConfigMap.

The `autobackup.sh` script is responsible for creating backups and can use the supplied `/usr/bin/sendmail` included in `/bin/busybox` to send email notifications about the backup status.

Here is an example of how the email notification might look:

```bash
cat << EOF 
From: "SAUVEGARDE @Gitea" <$BACKUP_FROM>
To: "Backup@Gitea" <$BACKUP_TO>
MIME-Version: 1.0
Subject: Sauvegarde Odoo $FQDN du $NOW 
Content-Type: multipart/mixed; boundary="-"

This is a MIME encoded message.  Decode it with "munpack"
or any other MIME reading software.  Mpack/munpack is available
via anonymous FTP in ftp.andrew.cmu.edu:pub/mpack/
---
Content-Type: text/plain

Voici la sauvegarde du $NOW
URL: https://$FQDN/
Highcanfly Gitea+ team

---
Content-Type: application/octet-stream; name="$FILENAME"
Content-Transfer-Encoding: base64
Content-Disposition: inline; filename="$FILENAME"

EOF
)    | (cat - && base64 < ${BACKUP_DIR}/$FILENAME && echo "" && echo "---")\
     | /usr/sbin/sendmail -f $BACKUP_FROM -S $SMTPD_SERVICE_HOST -t --
```

# Kubernetes ConfigMap

You can create a Kubernetes ConfigMap to supply the autobackup.sh script. Here is an example of how you might define such a ConfigMap:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: autobackup-script
data:
  autobackup.sh: |
    #!/bin/sh
    # Your backup script here
```
You can then mount this ConfigMap in your Kubernetes backup cron job specification:
```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: gitea-backup
spec:
  schedule: "0 0 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: gitea-backup
            image: highcanfly/gitea-backup
            volumeMounts:
            - name: autobackup-script-volume
              mountPath: /scripts
          volumes:
          - name: autobackup-script-volume
            configMap:
                defaultMode: 444
                items:
                - key: autobackup.sh
                  path: autobackup.sh
                name: autobackup-script
          restartPolicy: OnFailure

```