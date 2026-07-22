# XXL-JOB 2.5.0 虚谷数据库适配

## 初始化

1. 使用具备建库权限的虚谷账号执行 `tables_xxl_job_xugu.sql`。
2. 确认数据库名为 `XXL_JOB`，默认 schema 为连接用户 `SYSDBA`。
3. 启动调度中心时启用 `xugu` profile：

```shell
java -jar xxl-job-admin.jar --spring.profiles.active=xugu
```

生产环境应通过 `XXL_JOB_XUGU_URL`、`XXL_JOB_XUGU_USERNAME`、
`XXL_JOB_XUGU_PASSWORD` 覆盖数据库地址、用户名和密码。

## 兼容策略

- 默认 `application.properties` 和 `mybatis-mapper` 继续服务 MySQL。
- `application-xugu.properties` 将 Mapper 切换到 `mybatis-mapper-xugu`。
- 虚谷 Mapper 使用 `TIMESTAMPADD`、`MERGE INTO` 和 JDBC generated keys。
- `xxl_job_registry` 的三列唯一约束用于保证并发注册时只有一条记录。

## 升级已有数据库

从旧版 XXL-JOB 升级时，不应直接重复执行完整初始化脚本。应对照当前脚本补齐：

- 所有自增表的 identity 属性，以及 `xxl_job_lock` 的主键；
- `xxl_job_registry`、`xxl_job_log_report`、`xxl_job_user` 的唯一约束；
- `xxl_job_log` 的 `i_jobid_jobgroup` 和 `i_job_id` 索引。
