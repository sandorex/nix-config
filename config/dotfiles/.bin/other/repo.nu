#!/usr/bin/env nu
# basic nushell script to backup nushell save files
#
# can be used with mangohud or whatever `repo.nu mangohud %command%`

const SAVES_DIR = "saves"
const BACKUP_DIR = "saves-backup"

def --wrapped main [...command: string] {
    let basedir = if $nu.os-info.name == 'windows' {
        # TODO untested
        # just use global per-user path
        "~\AppData\LocalLow\semiwork\Repo"
    } else {
        # get path from PWD as steam sets it properly
        # steamapps/common/REPO -> steamapps/compatdata/3241660/...
        $env.PWD | path join "../../compatdata/3241660/pfx/drive_c/users/steamuser/AppData/LocalLow/semiwork/Repo/"
    }

    let saves = $basedir | path join $SAVES_DIR
    let backup = $basedir | path join $BACKUP_DIR

    # make sure backup dir exists
    mkdir $backup

    print "-------------------------------"
    print "REPO save backup script running"
    print "-------------------------------"

    job spawn {
        watch -r false $saves | where operation == Create | each { |e|
            # to make sure the files are properly saved
            sleep 5sec

            print $"REPO save file '($e.path | path basename)' backed up"

            # copy the save
            cp -r $e.path $backup
        }
    }

    # run the requested command
    ^$command
}
