# XXL-JOB 3.0.0 虚谷数据库适配说明

标签：`3.0.0-xugu`（基于上游 U1 = `b8c5b5af6c0e762ebe7a8063fc5703673d8ec6a5`，xxl-job 3.0.0）

## 变更范围

1. `doc/db/tables_xxl_job_xugu.sql`：虚谷建库/建表脚本，列集合与上游 3.0.0 MySQL 脚本
   `doc/db/tables_xxl_job.sql` 一一对应（上游 U0→U1 期间 DDL 无新增列，无需补列）。
2. `xxl-job-admin/pom.xml`：以 system scope 引入仓库内驱动
   `src/main/resources/lib/xugu-jdbc-12.3.6.jar`（`com.xugu:xugu-jdbc:12.3.6`）。
3. `xxl-job-admin/src/main/resources/application.properties`：
   `spring.datasource.url=jdbc:xugu://127.0.0.1:5138/XXL_JOB`，
   driver `com.xugu.cloudjdbc.Driver`。
4. `mybatis-mapper/XxlJobRegistryMapper.xml` + `XxlJobRegistryDao` + `JobRegistryHelper`：
   上游 `registrySaveOrUpdate`（MySQL `ON DUPLICATE KEY UPDATE`）在虚谷不可用，
   改为 `registryUpdate` + `registrySave` 的"先更新、未命中再插入"策略；
   `findDead`/`findAll` 的 `DATE_ADD(#{nowTime},INTERVAL -#{timeout} SECOND)` 改为
   `(sysdate - INTERVAL ${timeout} SECOND)`。
5. `XxlJobRegistryDaoTest`：与 DAO 方法签名同步（同上第 4 点）。
6. 集成测试 `src/test/java/com/xxl/job/admin/it/xugu/XuGuSchemaIT.java`：
   环境变量 `XUGU_IT=1`（配合 `-Pxugu-it` 与 `XUGU_JDBC_URL`）时才执行；
   连接真实引擎后在 stderr 打印 `XUGU_ENGINE_CONNECTED` / `XUGU_SCHEMA_APPLIED` 标记。

## 验证

```bash
mvn clean compile -DskipTests -Dlicense.skip=true -Drat.skip=true -pl xxl-job-admin -am -q
# 引擎联调（需要真实虚谷实例）：
XUGU_IT=1 XUGU_JDBC_URL=jdbc:xugu://127.0.0.1:5138/XXLJOB_TEST mvn test -pl xxl-job-admin -Pxugu-it
```
