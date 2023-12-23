
job "borgmatic" {
  datacenters = ["homelab"]
  priority = 50
  type = "service"
  meta {
    forcedeploy = "0"
  }
  constraint {
    attribute = "${node.class}"
    operator = "set_contains"
    value = "NAS"
  }

  group "borgmatic"{
    vault{
      policies= ["borgmatic"]

    }
    task "borgmatic" {
      driver = "docker"
      config {
        image = "ghcr.io/borgmatic-collective/borgmatic"
        volumes = [
          "/var/local/volume1:/var/local/volume1",
          "local/borgmatic.d:/etc/borgmatic.d",
          "secret/id_rsa:/root/.ssh/id_rsa",
          "/mnt/diskstation/nomad/borgmatic:/root/.cache/borg",
        ]

      }
      env {
      }

      template {
        data= <<EOH
BORG_RSH="ssh -i /root/.ssh/id_rsa -p 23"
{{ with secret "secrets/data/nomad/borgmatic"}}
BORG_PASSPHRASE= {{.Data.data.passphrase}}
{{end}}
          EOH
        destination = "secrets/sample.env"
        env = true
      }
      template {
        data= <<EOH
0 2 * * * PATH=$PATH:/usr/local/bin /usr/local/bin/borgmatic --create --prune -v 1
0 23 1 * * PATH=$PATH:/usr/local/bin /usr/local/bin/borgmatic  -check
          EOH
        destination = "local/borgmatic.d/crontab.txt"
      }
      template {
        data= <<EOH
location:
    # List of source directories to backup (required). Globs and
    # tildes are expanded. Do not backslash spaces in path names.
    source_directories:
    - /volume1/CardDav
    - /volume1/ebook
    - /volume1/git
    - /volume1/homes
    - /volume1/hubert
    - /volume1/music
    - /volume1/nomad
    - /volume1/photo

    repositories:
    - u304977@u304977.your-storagebox.de:{{if eq "production"  (env "meta.env") }}backup_hamelab{{else}}backup_homelab_dev{{end}}

    exclude_patterns:
        - '*/nomad/jellyfin/cache'
        - '*/loki/chunks'
        # - /home/*/.cache
        # - '*/.vim*.tmp'
        # - /etc/ssl
        # - /home/user/path with spaces

storage:
    extra_borg_options:
        # Extra command-line options to pass to "borg init".
        # init: --extra-option

        # Extra command-line options to pass to "borg prune".
        # prune: --extra-option

        # Extra command-line options to pass to "borg compact".
        # compact: --extra-option

        # Extra command-line options to pass to "borg create".
        create: --progress --stats

        # Extra command-line options to pass to "borg check".
        # check: --extra-option

retention:
    # Keep all archives within this time interval.
    # keep_within: 3H

    # Number of secondly archives to keep.
    # keep_secondly: 60

    # Number of minutely archives to keep.
    # keep_minutely: 60

    # Number of hourly archives to keep.
    # keep_hourly: 24

    # Number of daily archives to keep.
    keep_daily: 7

    # Number of weekly archives to keep.
    keep_weekly: 4

    # Number of monthly archives to keep.
    # keep_monthly: 6

    # Number of yearly archives to keep.
    # keep_yearly: 1

consistency:
    checks:
    - repository
        # - archives
    # check_repositories:
        # - user@backupserver:sourcehostname.borg
    # check_last: 3
# output:
    # color: false

# hooks:
    # List of one or more shell commands or scripts to execute
    # before creating a backup, run once per configuration file.
    # before_backup:
        # - echo "Starting a backup."

    # List of one or more shell commands or scripts to execute
    # before pruning, run once per configuration file.
    # before_prune:
        # - echo "Starting pruning."

    # List of one or more shell commands or scripts to execute
    # before compaction, run once per configuration file.
    # before_compact:
        # - echo "Starting compaction."

    # List of one or more shell commands or scripts to execute
    # before consistency checks, run once per configuration file.
    # before_check:
        # - echo "Starting checks."

    # List of one or more shell commands or scripts to execute
    # before extracting a backup, run once per configuration file.
    # before_extract:
        # - echo "Starting extracting."

    # List of one or more shell commands or scripts to execute
    # after creating a backup, run once per configuration file.
    # after_backup:
        # - echo "Finished a backup."

    # List of one or more shell commands or scripts to execute
    # after compaction, run once per configuration file.
    # after_compact:
        # - echo "Finished compaction."

    # List of one or more shell commands or scripts to execute
    # after pruning, run once per configuration file.
    # after_prune:
        # - echo "Finished pruning."

    # List of one or more shell commands or scripts to execute
    # after consistency checks, run once per configuration file.
    # after_check:
        # - echo "Finished checks."

    # List of one or more shell commands or scripts to execute
    # after extracting a backup, run once per configuration file.
    # after_extract:
        # - echo "Finished extracting."

    # List of one or more shell commands or scripts to execute
    # when an exception occurs during a "prune", "compact",
    # "create", or "check" action or an associated before/after
    # hook.
    # on_error:
        # - echo "Error during prune/compact/create/check."

    # List of one or more shell commands or scripts to execute
    # before running all actions (if one of them is "create").
    # These are collected from all configuration files and then
    # run once before all of them (prior to all actions).
    # before_everything:
        # - echo "Starting actions."

    # List of one or more shell commands or scripts to execute
    # after running all actions (if one of them is "create").
    # These are collected from all configuration files and then
    # run once after all of them (after any action).
    # after_everything:
        # - echo "Completed actions."
          EOH
        destination = "local/borgmatic.d/config.yaml"
      }
      template {
        data= <<EOH
{{ with secret "secrets/data/nomad/borgmatic"}}
{{.Data.data.privatekey}}
{{end}}
          EOH
        destination = "secret/id_rsa"
        perms= "700"
      }
      resources {
        memory = 300
      }
    }

  }
}
