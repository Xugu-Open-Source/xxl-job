package com.xxl.job.admin.business.mapper;

import org.junit.jupiter.api.Test;
import org.springframework.util.StreamUtils;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class XuguMapperCompatibilityTest {

    private static final String BUSINESS_MAPPER_ROOT = "mapper-xugu/business/";
    private static final String UPGRADE_SCRIPT = "../doc/db/upgrade_xxl_job_xugu_2.5.0_to_3.4.2.sql";

    @Test
    void registryMapperUsesParameterizedXuguSyntax() throws IOException {
        String mapper = readResource(BUSINESS_MAPPER_ROOT + "XxlJobRegistryMapper.xml");

        assertTrue(mapper.contains("TIMESTAMPADD(SECOND, -#{timeout}, #{nowTime})"));
        assertTrue(mapper.contains("MERGE INTO xxl_job_registry"));
        assertFalse(mapper.contains("DATE_ADD("));
        assertFalse(mapper.contains("ON DUPLICATE KEY UPDATE"));
        assertFalse(mapper.contains("${timeout}"));
    }

    @Test
    void logReportMapperUsesXuguMerge() throws IOException {
        String mapper = readResource(BUSINESS_MAPPER_ROOT + "XxlJobLogReportMapper.xml");

        assertTrue(mapper.contains("MERGE INTO xxl_job_log_report"));
        assertFalse(mapper.contains("ON DUPLICATE KEY UPDATE"));
    }

    @Test
    void logMapperUsesEquivalentFailurePredicate() throws IOException {
        String mapper = readResource(BUSINESS_MAPPER_ROOT + "XxlJobLogMapper.xml");

        assertTrue(mapper.contains("trigger_code not in (0, 200) or handle_code != 0"));
        assertTrue(mapper.contains("handle_code != 200"));
        assertFalse(mapper.contains("WHERE !("));
    }

    @Test
    void xuguMappersUseJdbcGeneratedKeys() throws IOException {
        assertGeneratedKeys("XxlJobGroupMapper.xml");
        assertGeneratedKeys("XxlJobInfoMapper.xml");
        assertGeneratedKeys("XxlJobLogMapper.xml");
        assertGeneratedKeys("XxlJobLogGlueMapper.xml");
        assertGeneratedKeys("XxlJobLogReportMapper.xml");
        assertGeneratedKeys("framework/XxlJobUserMapper.xml");
    }

    @Test
    void upgradeScriptPreservesRegistryGeneratedKeysAndUsesQualifiedIndexes() throws IOException {
        String script = readProjectFile(UPGRADE_SCRIPT);

        assertTrue(script.contains("bigint IDENTITY(2147483648, 1)"));
        assertTrue(script.contains("DROP INDEX xxl_job_log.i_jobid_jobgroup"));
        assertTrue(script.contains("DROP INDEX xxl_job_log.i_job_id"));
    }

    private void assertGeneratedKeys(String mapperName) throws IOException {
        String mapperPath = mapperName.startsWith("framework/")
                ? "mapper-xugu/" + mapperName
                : BUSINESS_MAPPER_ROOT + mapperName;
        String mapper = readResource(mapperPath);
        assertTrue(mapper.contains("useGeneratedKeys=\"true\""), mapperName);
        assertTrue(mapper.contains("keyProperty=\"id\""), mapperName);
        assertFalse(mapper.contains("LAST_INSERT_ID()"), mapperName);
    }

    private String readResource(String resourceName) throws IOException {
        try (InputStream input = getClass().getClassLoader().getResourceAsStream(resourceName)) {
            if (input == null) {
                throw new IOException("Resource not found: " + resourceName);
            }
            return StreamUtils.copyToString(input, StandardCharsets.UTF_8);
        }
    }

    private String readProjectFile(String relativePath) throws IOException {
        return java.nio.file.Files.readString(java.nio.file.Path.of(relativePath), StandardCharsets.UTF_8);
    }
}
