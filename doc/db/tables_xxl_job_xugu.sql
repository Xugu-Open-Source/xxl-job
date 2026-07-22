-- XXL-JOB 2.5.0 虚谷数据库初始化脚本

USE SYSTEM;
CREATE DATABASE IF NOT EXISTS XXL_JOB CHARACTER SET UTF8;
USE XXL_JOB;

CREATE TABLE xxl_job_info (
    id integer NOT NULL,
    job_group integer NOT NULL COMMENT '执行器主键ID',
    job_desc varchar(255) NOT NULL,
    add_time datetime,
    update_time datetime,
    author varchar(64) COMMENT '作者',
    alarm_email varchar(255) COMMENT '报警邮件',
    schedule_type varchar(50) NOT NULL DEFAULT 'NONE' COMMENT '调度类型',
    schedule_conf varchar(128) COMMENT '调度配置，值含义取决于调度类型',
    misfire_strategy varchar(50) NOT NULL DEFAULT 'DO_NOTHING' COMMENT '调度过期策略',
    executor_route_strategy varchar(50) COMMENT '执行器路由策略',
    executor_handler varchar(255) COMMENT '执行器任务handler',
    executor_param varchar(512) COMMENT '执行器任务参数',
    executor_block_strategy varchar(50) COMMENT '阻塞处理策略',
    executor_timeout integer NOT NULL DEFAULT 0 COMMENT '任务执行超时时间，单位秒',
    executor_fail_retry_count integer NOT NULL DEFAULT 0 COMMENT '失败重试次数',
    glue_type varchar(50) NOT NULL COMMENT 'GLUE类型',
    glue_source clob COMMENT 'GLUE源代码',
    glue_remark varchar(128) COMMENT 'GLUE备注',
    glue_updatetime datetime COMMENT 'GLUE更新时间',
    child_jobid varchar(255) COMMENT '子任务ID，多个逗号分隔',
    trigger_status tinyint NOT NULL DEFAULT 0 COMMENT '调度状态：0-停止，1-运行',
    trigger_last_time bigint NOT NULL DEFAULT 0 COMMENT '上次调度时间',
    trigger_next_time bigint NOT NULL DEFAULT 0 COMMENT '下次调度时间'
);

CREATE TABLE xxl_job_log (
    id bigint NOT NULL,
    job_group integer NOT NULL COMMENT '执行器主键ID',
    job_id integer NOT NULL COMMENT '任务，主键ID',
    executor_address varchar(255) COMMENT '执行器地址，本次执行的地址',
    executor_handler varchar(255) COMMENT '执行器任务handler',
    executor_param varchar(512) COMMENT '执行器任务参数',
    executor_sharding_param varchar(20) COMMENT '执行器任务分片参数，格式如 1/2',
    executor_fail_retry_count integer NOT NULL DEFAULT 0 COMMENT '失败重试次数',
    trigger_time datetime COMMENT '调度-时间',
    trigger_code integer NOT NULL COMMENT '调度-结果',
    trigger_msg clob COMMENT '调度-日志',
    handle_time datetime COMMENT '执行-时间',
    handle_code integer NOT NULL COMMENT '执行-状态',
    handle_msg clob COMMENT '执行-日志',
    alarm_status tinyint NOT NULL DEFAULT 0 COMMENT '告警状态：0-默认、1-无需告警、2-告警成功、3-告警失败'
);

CREATE TABLE xxl_job_log_report (
    id integer NOT NULL,
    trigger_day datetime COMMENT '调度-时间',
    running_count integer NOT NULL DEFAULT 0 COMMENT '运行中-日志数量',
    suc_count integer NOT NULL DEFAULT 0 COMMENT '执行成功-日志数量',
    fail_count integer NOT NULL DEFAULT 0 COMMENT '执行失败-日志数量',
    update_time datetime
);

CREATE TABLE xxl_job_logglue (
    id integer NOT NULL,
    job_id integer NOT NULL COMMENT '任务，主键ID',
    glue_type varchar(50) COMMENT 'GLUE类型',
    glue_source clob COMMENT 'GLUE源代码',
    glue_remark varchar(128) NOT NULL COMMENT 'GLUE备注',
    add_time datetime,
    update_time datetime
);

CREATE TABLE xxl_job_registry (
    id integer NOT NULL,
    registry_group varchar(50) NOT NULL,
    registry_key varchar(255) NOT NULL,
    registry_value varchar(255) NOT NULL,
    update_time datetime
);

CREATE TABLE xxl_job_group (
    id integer NOT NULL,
    app_name varchar(64) NOT NULL COMMENT '执行器AppName',
    title varchar(12) NOT NULL COMMENT '执行器名称',
    address_type tinyint NOT NULL DEFAULT 0 COMMENT '执行器地址类型：0=自动注册、1=手动录入',
    address_list clob COMMENT '执行器地址列表，多地址逗号分隔',
    update_time datetime
);

CREATE TABLE xxl_job_user (
    id integer NOT NULL,
    username varchar(50) NOT NULL COMMENT '账号',
    password varchar(50) NOT NULL COMMENT '密码',
    role tinyint NOT NULL COMMENT '角色：0-普通用户、1-管理员',
    permission varchar(255) COMMENT '权限：执行器ID列表，多个逗号分割'
);

CREATE TABLE xxl_job_lock (
    lock_name varchar(50) NOT NULL COMMENT '锁名称'
);

ALTER TABLE xxl_job_info ALTER COLUMN id integer IDENTITY(2, 1) CASCADE;
ALTER TABLE xxl_job_log ALTER COLUMN id bigint IDENTITY(1, 1) CASCADE;
ALTER TABLE xxl_job_log_report ALTER COLUMN id integer IDENTITY(1, 1) CASCADE;
ALTER TABLE xxl_job_logglue ALTER COLUMN id integer IDENTITY(1, 1) CASCADE;
ALTER TABLE xxl_job_registry ALTER COLUMN id integer IDENTITY(1, 1) CASCADE;
ALTER TABLE xxl_job_group ALTER COLUMN id integer IDENTITY(2, 1) CASCADE;
ALTER TABLE xxl_job_user ALTER COLUMN id integer IDENTITY(2, 1) CASCADE;

ALTER TABLE xxl_job_lock ADD CONSTRAINT pk_xxl_job_lock PRIMARY KEY (lock_name);

ALTER TABLE xxl_job_log_report ADD CONSTRAINT uk_xxl_job_log_report_trigger_day UNIQUE (trigger_day);
ALTER TABLE xxl_job_registry ADD CONSTRAINT uk_xxl_job_registry_gkv UNIQUE (registry_group, registry_key, registry_value);
ALTER TABLE xxl_job_user ADD CONSTRAINT uk_xxl_job_user_username UNIQUE (username);

CREATE INDEX i_trigger_time ON xxl_job_log (trigger_time) INDEXTYPE IS BTREE;
CREATE INDEX i_handle_code ON xxl_job_log (handle_code) INDEXTYPE IS BTREE;
CREATE INDEX i_jobid_jobgroup ON xxl_job_log (job_id, job_group) INDEXTYPE IS BTREE;
CREATE INDEX i_job_id ON xxl_job_log (job_id) INDEXTYPE IS BTREE;

INSERT INTO xxl_job_group (
    id, app_name, title, address_type, address_list, update_time
) VALUES (
    1, 'xxl-job-executor-sample', '示例执行器', 0, NULL, '2018-11-03 22:21:31'
);

INSERT INTO xxl_job_info (
    id, job_group, job_desc, add_time, update_time, author, alarm_email,
    schedule_type, schedule_conf, misfire_strategy, executor_route_strategy,
    executor_handler, executor_param, executor_block_strategy, executor_timeout,
    executor_fail_retry_count, glue_type, glue_source, glue_remark,
    glue_updatetime, child_jobid
) VALUES (
    1, 1, '测试任务1', '2018-11-03 22:21:31', '2018-11-03 22:21:31',
    'XXL', '', 'CRON', '0 0 0 * * ? *', 'DO_NOTHING', 'FIRST',
    'demoJobHandler', '', 'SERIAL_EXECUTION', 0, 0, 'BEAN', '',
    'GLUE代码初始化', '2018-11-03 22:21:31', ''
);

INSERT INTO xxl_job_user (
    id, username, password, role, permission
) VALUES (
    1, 'admin', 'e10adc3949ba59abbe56e057f20f883e', 1, NULL
);

INSERT INTO xxl_job_lock (lock_name) VALUES ('schedule_lock');

COMMIT;
