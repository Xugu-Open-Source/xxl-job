# XXL-JOB 3.4.2 虚谷数据库适配

## 环境要求

- JDK 17 或更高版本；构建时确认 `JAVA_HOME` 不再指向 JDK 8。
- 虚谷数据库服务端和 JDBC 驱动版本应进行兼容性确认。
- 默认使用 `com.xugudb:xugu-jdbc:12.3.6`。

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

- 默认 `application.properties` 和 `mapper` 继续服务 MySQL。
- `application-xugu.properties` 将 Mapper 切换到 `mapper-xugu`。
- 虚谷 Mapper 使用 `TIMESTAMPADD`、`MERGE INTO` 和 JDBC generated keys。
- 注册表和日志报表通过唯一约束配合 `MERGE INTO` 保证并发写入语义。
