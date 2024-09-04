use `system`;
CREATE database if NOT EXISTS `xxl_job` character set utf8;
use `xxl_job`;



CREATE TABLE XXL_JOB_QRTZ_JOB_DETAILS
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    JOB_NAME  VARCHAR(200) NOT NULL,
    JOB_GROUP VARCHAR(200) NOT NULL,
    DESCRIPTION VARCHAR(250) NULL,
    JOB_CLASS_NAME   VARCHAR(250) NOT NULL,
    IS_DURABLE VARCHAR(1) NOT NULL,
    IS_NONCONCURRENT VARCHAR(1) NOT NULL,
    IS_UPDATE_DATA VARCHAR(1) NOT NULL,
    REQUESTS_RECOVERY VARCHAR(1) NOT NULL,
    JOB_DATA BLOB NULL,
    PRIMARY KEY (SCHED_NAME,JOB_NAME,JOB_GROUP)
);

CREATE TABLE XXL_JOB_QRTZ_TRIGGERS
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    JOB_NAME  VARCHAR(200) NOT NULL,
    JOB_GROUP VARCHAR(200) NOT NULL,
    DESCRIPTION VARCHAR(250) NULL,
    NEXT_FIRE_TIME BIGINT NULL,
    PREV_FIRE_TIME BIGINT NULL,
    PRIORITY INTEGER NULL,
    TRIGGER_STATE VARCHAR(16) NOT NULL,
    TRIGGER_TYPE VARCHAR(8) NOT NULL,
    START_TIME BIGINT NOT NULL,
    END_TIME BIGINT NULL,
    CALENDAR_NAME VARCHAR(200) NULL,
    MISFIRE_INSTR SMALLINT NULL,
    JOB_DATA BLOB NULL,
    PRIMARY KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP),
    FOREIGN KEY (SCHED_NAME,JOB_NAME,JOB_GROUP)
        REFERENCES XXL_JOB_QRTZ_JOB_DETAILS(SCHED_NAME,JOB_NAME,JOB_GROUP)
);

CREATE TABLE XXL_JOB_QRTZ_SIMPLE_TRIGGERS
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    REPEAT_COUNT BIGINT NOT NULL,
    REPEAT_INTERVAL BIGINT NOT NULL,
    TIMES_TRIGGERED BIGINT NOT NULL,
    PRIMARY KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP),
    FOREIGN KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
        REFERENCES XXL_JOB_QRTZ_TRIGGERS(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
);

CREATE TABLE XXL_JOB_QRTZ_CRON_TRIGGERS
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    CRON_EXPRESSION VARCHAR(200) NOT NULL,
    TIME_ZONE_ID VARCHAR(80),
    PRIMARY KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP),
    FOREIGN KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
        REFERENCES XXL_JOB_QRTZ_TRIGGERS(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
);

CREATE TABLE XXL_JOB_QRTZ_SIMPROP_TRIGGERS
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    STR_PROP_1 VARCHAR(512) NULL,
    STR_PROP_2 VARCHAR(512) NULL,
    STR_PROP_3 VARCHAR(512) NULL,
    INT_PROP_1 INT NULL,
    INT_PROP_2 INT NULL,
    LONG_PROP_1 BIGINT NULL,
    LONG_PROP_2 BIGINT NULL,
    DEC_PROP_1 NUMERIC(13,4) NULL,
    DEC_PROP_2 NUMERIC(13,4) NULL,
    BOOL_PROP_1 VARCHAR(1) NULL,
    BOOL_PROP_2 VARCHAR(1) NULL,
    PRIMARY KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP),
    FOREIGN KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
        REFERENCES XXL_JOB_QRTZ_TRIGGERS(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
);

CREATE TABLE XXL_JOB_QRTZ_BLOB_TRIGGERS
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    BLOB_DATA BLOB NULL,
    PRIMARY KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP),
    FOREIGN KEY (SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
        REFERENCES XXL_JOB_QRTZ_TRIGGERS(SCHED_NAME,TRIGGER_NAME,TRIGGER_GROUP)
);

CREATE TABLE XXL_JOB_QRTZ_CALENDARS
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    CALENDAR_NAME  VARCHAR(200) NOT NULL,
    CALENDAR BLOB NOT NULL,
    PRIMARY KEY (SCHED_NAME,CALENDAR_NAME)
);

CREATE TABLE XXL_JOB_QRTZ_PAUSED_TRIGGER_GRPS
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    TRIGGER_GROUP  VARCHAR(200) NOT NULL,
    PRIMARY KEY (SCHED_NAME,TRIGGER_GROUP)
);

CREATE TABLE XXL_JOB_QRTZ_FIRED_TRIGGERS
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    ENTRY_ID VARCHAR(95) NOT NULL,
    TRIGGER_NAME VARCHAR(200) NOT NULL,
    TRIGGER_GROUP VARCHAR(200) NOT NULL,
    INSTANCE_NAME VARCHAR(200) NOT NULL,
    FIRED_TIME BIGINT NOT NULL,
    SCHED_TIME BIGINT NOT NULL,
    PRIORITY INTEGER NOT NULL,
    STATE VARCHAR(16) NOT NULL,
    JOB_NAME VARCHAR(200) NULL,
    JOB_GROUP VARCHAR(200) NULL,
    IS_NONCONCURRENT VARCHAR(1) NULL,
    REQUESTS_RECOVERY VARCHAR(1) NULL,
    PRIMARY KEY (SCHED_NAME,ENTRY_ID)
);

CREATE TABLE XXL_JOB_QRTZ_SCHEDULER_STATE
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    INSTANCE_NAME VARCHAR(200) NOT NULL,
    LAST_CHECKIN_TIME BIGINT NOT NULL,
    CHECKIN_INTERVAL BIGINT NOT NULL,
    PRIMARY KEY (SCHED_NAME,INSTANCE_NAME)
);

CREATE TABLE XXL_JOB_QRTZ_LOCKS
(
    SCHED_NAME VARCHAR(120) NOT NULL,
    LOCK_NAME  VARCHAR(40) NOT NULL,
    PRIMARY KEY (SCHED_NAME,LOCK_NAME)
);

CREATE TABLE `xxl_job_qrtz_trigger_info` (
                                             `id` int AUTO_INCREMENT,
                                             `job_group` varchar(255) NOT NULL COMMENT '任务组',
                                             `job_name` varchar(255) NOT NULL COMMENT '任务名',
                                             `job_cron` varchar(128) NOT NULL COMMENT '任务执行CORN',
                                             `job_desc` varchar(255) NOT NULL,
                                             `job_class` varchar(255) NOT NULL COMMENT '任务执行JobBean',
                                             `add_time` datetime DEFAULT NULL,
                                             `update_time` datetime DEFAULT NULL,
                                             `author` varchar(64) DEFAULT NULL COMMENT '作者',
                                             `alarm_email` varchar(255) DEFAULT NULL COMMENT '报警邮件',
                                             `alarm_threshold` int DEFAULT NULL COMMENT '报警阀值(连续失败次数)',
                                             `executor_address` varchar(255) DEFAULT NULL COMMENT '执行器地址，有多个则逗号分隔',
                                             `executor_handler` varchar(255) DEFAULT NULL COMMENT '执行器任务handler',
                                             `executor_param` varchar(255) DEFAULT NULL COMMENT '执行器任务参数',
                                             `glue_switch` int DEFAULT '0' COMMENT 'GLUE模式开关：0-否，1-是',
                                             `glue_source` text COMMENT 'GLUE源代码',
                                             `glue_remark` varchar(128) DEFAULT NULL COMMENT 'GLUE备注',
                                             PRIMARY KEY (`id`)
);

CREATE TABLE `xxl_job_qrtz_trigger_log` (
                                            `id` int AUTO_INCREMENT,
                                            `job_group` varchar(255) NOT NULL COMMENT '任务组',
                                            `job_name` varchar(255) NOT NULL COMMENT '任务名',
                                            `job_cron` varchar(128) NOT NULL COMMENT '任务执行CORN表达式',
                                            `job_desc` varchar(255) NOT NULL,
                                            `job_class` varchar(255) NOT NULL COMMENT '任务执行JobBean',
                                            `executor_address` varchar(255) DEFAULT NULL COMMENT '执行器地址，本次执行的地址',
                                            `executor_handler` varchar(255) DEFAULT NULL COMMENT '执行器任务handler',
                                            `executor_param` varchar(255) DEFAULT NULL COMMENT 'executor_param',
                                            `trigger_time` datetime DEFAULT NULL COMMENT '调度-时间',
                                            `trigger_status` varchar(255) DEFAULT NULL COMMENT '调度-结果',
                                            `trigger_msg` varchar(2048) DEFAULT NULL COMMENT '调度-日志',
                                            `handle_time` datetime DEFAULT NULL COMMENT '执行-时间',
                                            `handle_status` varchar(255) DEFAULT NULL COMMENT '执行-状态',
                                            `handle_msg` varchar(2048) DEFAULT NULL COMMENT '执行-日志',
                                            PRIMARY KEY (`id`)
);

CREATE TABLE `xxl_job_qrtz_trigger_logglue` (
                                                `id` int AUTO_INCREMENT,
                                                `job_group` varchar(255) NOT NULL,
                                                `job_name` varchar(255) NOT NULL,
                                                `glue_source` text,
                                                `glue_remark` varchar(128) NOT NULL,
                                                `add_time` timestamp NULL DEFAULT NULL,
                                                `update_time` timestamp NULL DEFAULT NULL,
                                                PRIMARY KEY (`id`)
);



commit;

