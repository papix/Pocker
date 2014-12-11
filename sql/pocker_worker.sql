CREATE TABLE IF NOT EXISTS func (
    id         INT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
    name       VARCHAR(255) NOT NULL,
    UNIQUE(name)
);
CREATE TABLE IF NOT EXISTS job (
    id              BIGINT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
    func_id         INTEGER UNSIGNED NOT NULL,
    arg             MEDIUMBLOB,
    uniqkey         VARCHAR(255) NULL,
    enqueue_time    INTEGER UNSIGNED,
    grabbed_until   INTEGER UNSIGNED NOT NULL,
    run_after       INTEGER UNSIGNED NOT NULL DEFAULT 0,
    retry_cnt       INTEGER UNSIGNED NOT NULL DEFAULT 0,
    priority        INTEGER UNSIGNED NOT NULL DEFAULT 0,
    UNIQUE(func_id, uniqkey),
    KEY priority (priority)
);
CREATE TABLE IF NOT EXISTS exception_log (
    id              BIGINT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
    func_id         INTEGER UNSIGNED NOT NULL DEFAULT 0,
    exception_time  INTEGER UNSIGNED NOT NULL,
    message         MEDIUMBLOB NOT NULL,
    uniqkey         VARCHAR(255) NULL,
    arg             MEDIUMBLOB,
    retried         TINYINT(1) NOT NULL DEFAULT 0,
    INDEX (func_id),
    INDEX (exception_time)
);
CREATE TABLE IF NOT EXISTS job_status (
    id              BIGINT UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
    func_id         INTEGER UNSIGNED NOT NULL DEFAULT 0,
    arg             MEDIUMBLOB NOT NULL,
    uniqkey         VARCHAR(255) NULL,
    status          VARCHAR(10),
    job_start_time  INTEGER UNSIGNED NOT NULL,
    job_end_time    INTEGER UNSIGNED NOT NULL
);
