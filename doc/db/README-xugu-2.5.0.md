# XXL-JOB 2.5.0 虚谷数据库适配说明

标签：`2.5.0-xugu`  
基线：上游 [xuxueli/xxl-job@2.5.0](https://github.com/xuxueli/xxl-job/tree/2.5.0)

## 使用步骤

1. 使用客户端连接虚谷（可先连 `SYSTEM`），执行 `doc/db/tables_xxl_job_xugu.sql`，创建独立库 `XXL_JOB` 及表、初始数据。
2. 按环境修改 `xxl-job-admin/src/main/resources/application.properties` 中的数据源（默认占位）：

```properties
spring.datasource.url=jdbc:xugu://127.0.0.1:5138/XXL_JOB
spring.datasource.username=SYSDBA
spring.datasource.password=SYSDBA
spring.datasource.driver-class-name=com.xugu.cloudjdbc.Driver
```

3. 构建并启动 `xxl-job-admin`（驱动已打包在 `xxl-job-admin/src/main/resources/lib/xugu-jdbc-12.3.6.jar`）。
4. 浏览器访问 `/xxl-job-admin`，默认账号 `admin` / `123456`。

## 相对上游 2.5.0 的主要改动

| 改动 | 说明 |
|------|------|
| JDBC 驱动 | MySQL → 虚谷 `xugu-jdbc` 12.3.6（system 依赖） |
| 数据源配置 | 虚谷占位 URL / SYSDBA |
| 建表脚本 | 新增 `tables_xxl_job_xugu.sql` |
| Registry | 去掉 `ON DUPLICATE KEY UPDATE`，改为 update-then-insert |
| Registry 时间条件 | `DATE_ADD` → `sysdate - INTERVAL n SECOND` |
| 失败日志查询 | `WHERE !(...)` → 等价布尔改写 |

## 说明

- 本适配沿用历史 `*-xugu` 模式：直接修改 admin 落库相关点，非独立方言插件。
- 默认配置使用占位地址，请勿依赖仓库内测试环境 IP。
