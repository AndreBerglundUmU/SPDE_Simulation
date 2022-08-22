function backupSave(fileName,data)
    backUpPause = 1;
    % Backup the results (as well as the backup itself)
    backup2 = [fileName 'Temp'];
    if isfile(fileName)
        copyfile(fileName,backup2)
        pause(backUpPause)
    end
    parforSave(fileName,data);
    pause(backUpPause)
    % Remove second backup, now that primary backup worked
    if isfile(backup2)
        delete(backup2)
    end
    pause(backUpPause)
end

function parforSave(fileNameString,variable)
    save(fileNameString,'variable', '-v7.3');
end