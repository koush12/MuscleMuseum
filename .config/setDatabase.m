function setDatabase()
%% Load database configuration
disp(newline + "Setting PostgreSQL dataBase...")
load("Config.mat","DatabaseConfig","DatabaseServerConfig")
localServer = DatabaseServerConfig(DatabaseServerConfig.Name == "localhost",:);
remoteServer = DatabaseServerConfig(DatabaseServerConfig.Name ~= "localhost",:);

for isLocal = [true,false]
    if isLocal
        serverConfig = localServer;
        serverName = "local";
        newDatabaseList = DatabaseConfig.Name + "_local";
        warningMessage = ...
            "Can not connect to the local PostgreSQL server. " + ...
            "Please check if you have installed PostgreSQL: " + newline +  ...
            "https://www.postgresql.org/download/" + newline + ...
            "Please also check if the local PSQL server username/password are set correctly in setConfig.m." + newline;
    else
        serverConfig = remoteServer;
        serverName = "remote";
        newDatabaseList = DatabaseConfig.Name;
        warningMessage = ...
            "Can not connect to the remote PostgreSQL server. " + ...
            "Please check the internet/ethernet connection to the remote PostgreSQL server. " + newline +  ...
            "Please also check if the remote PSQL server username/password are set correctly in setConfig.m." + newline;
    end

    %% Connect to the server
    try
        disp("Connecting to the "+ serverName +" server...")
        conn = connectPsqlDatabase( ...
            "postgres", ...
            serverConfig.Name, ...
            serverConfig.Port, ...
            serverConfig.Username, ...
            serverConfig.Password,...
            false);
        disp("Success. Start to check database status...")
    catch me
        warning(warningMessage + ...
            "Error message: " + me.message)
        continue
    end

    %% Check/create databases and users
    query = "SELECT datname FROM pg_catalog.pg_database;";
    dbList = pgFetch(conn,query);
    if all(ismember(newDatabaseList,dbList.datname))
        disp("All required databases were created.")
    else
        disp('Required databases are missing. Attempting to create new databases and users...')
        for ii = 1: numel(newDatabaseList)
            try
                execute(conn,append("CREATE DATABASE ",newDatabaseList(ii)))
                disp(append('Database [',newDatabaseList(ii),'] created'))
            catch ME
                warning(ME.message)
            end
        end

        newUserList = ["writer","reader"];
        for ii = 1:numel(newUserList)
            try
                execute(conn,append("CREATE ROLE ",newUserList(ii),' WITH LOGIN PASSWORD ''',newUserList(ii),''''))
                disp(append('User ',newUserList(ii),' created'))
            catch ME
                warning(ME.message)
            end
        end
    end
    close(conn)

    %% Check database tables
    isMissing = 0;
    for ii = 1:numel(newDatabaseList)
        conn = connectPsqlDatabase( ...
            newDatabaseList(ii), ...
            serverConfig.Name, ...
            serverConfig.Port, ...
            serverConfig.Username, ...
            serverConfig.Password,...
            false);
        query = "SELECT table_name " + ...
            "FROM information_schema.tables " + ...
            "WHERE table_schema = 'public' " + ...
            "AND table_type = 'BASE TABLE';";
        tableList = pgFetch(conn,query);
        tableList = tableList.table_name;
        newTableList = DatabaseConfig.Table(ii);
        newTableList = newTableList{1};
        if any(~ismember(newTableList,tableList))
            isMissing = 1;
        end
        close(conn)
    end

    if isMissing
        disp('Required database tables are missing. Attempting to create new tables...')
    else
        disp("All required database tables were created.")
        continue
    end

    %% Create database tables
    for ii = 1:numel(newDatabaseList)
        conn = connectPsqlDatabase( ...
            newDatabaseList(ii), ...
            serverConfig.Name, ...
            serverConfig.Port, ...
            serverConfig.Username, ...
            serverConfig.Password,...
            false);
        newTableList = DatabaseConfig.Table(ii);
        newTableList = newTableList{1};
        for jj = 1:numel(newTableList)
            try
                execute(conn,"CREATE TABLE " + newTableList(jj) + "(" + ...
                    """SerialNumber"" serial," + ...
                    """DateTime"" timestamp," + ...
                    """Name"" varchar," + ...
                    """NRun"" integer," + ...
                    """NCompletedRun"" integer" + ...
                    ");")
                disp("Table [" + newTableList(jj) + "] created in database [" ...
                    + newDatabaseList(ii) + "].")
            catch ME
                warning(ME.message)
            end
        end
        close(conn)
    end

    %% Grant permissions
    for ii = 1:numel(newDatabaseList)
        conn = connectPsqlDatabase( ...
            newDatabaseList(ii), ...
            serverConfig.Name, ...
            serverConfig.Port, ...
            serverConfig.Username, ...
            serverConfig.Password,...
            false);

        tableList = fetch(conn,"SELECT table_name FROM information_schema.tables  WHERE table_schema='public' AND table_type='BASE TABLE'");
        disp('Attempting to grant privileges to users...')
        try
            execute(conn,append("GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA public TO ","writer"))
            execute(conn,append("GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO ","writer"))
            for jj = 1:numel(tableList.table_name)
                execute(conn,append("ALTER TABLE ",tableList.table_name(jj)," OWNER TO ","writer"))
            end
            disp(append('User [writer] granted for database [',newDatabaseList(ii),']'))
        catch ME
            warning(ME.message)
        end

        try
            execute(conn,append("GRANT SELECT ON ALL TABLES IN SCHEMA public TO ","reader"))
            disp(append('User [reader] granted for database [',newDatabaseList(ii),']'))
        catch ME
            warning(ME.message)
        end

        close(conn)
    end

end
disp("Done.")
end





