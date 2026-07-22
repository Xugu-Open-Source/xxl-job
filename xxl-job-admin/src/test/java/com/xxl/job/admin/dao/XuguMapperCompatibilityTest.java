package com.xxl.job.admin.dao;

import org.junit.jupiter.api.Test;
import org.springframework.util.StreamUtils;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class XuguMapperCompatibilityTest {

    private static final String MAPPER_ROOT = "mybatis-mapper-xugu/";

    @Test
    void registryMapperUsesParameterizedXuguSyntax() throws IOException {
        String mapper = readMapper("XxlJobRegistryMapper.xml");

        assertTrue(mapper.contains("TIMESTAMPADD(SECOND, -#{timeout}, #{nowTime})"));
        assertTrue(mapper.contains("MERGE INTO xxl_job_registry"));
        assertFalse(mapper.contains("DATE_ADD("));
        assertFalse(mapper.contains("ON DUPLICATE KEY UPDATE"));
        assertFalse(mapper.contains("${timeout}"));
    }

    @Test
    void logMapperUsesEquivalentFailurePredicate() throws IOException {
        String mapper = readMapper("XxlJobLogMapper.xml");

        assertTrue(mapper.contains("trigger_code not in (0, 200) or handle_code != 0"));
        assertTrue(mapper.contains("handle_code != 200"));
        assertFalse(mapper.contains("WHERE !("));
    }

    @Test
    void insertMappersUseJdbcGeneratedKeys() throws IOException {
        assertGeneratedKeys("XxlJobInfoMapper.xml");
        assertGeneratedKeys("XxlJobLogMapper.xml");
        assertGeneratedKeys("XxlJobLogGlueMapper.xml");
        assertGeneratedKeys("XxlJobLogReportMapper.xml");
    }


    private void assertGeneratedKeys(String mapperName) throws IOException {
        String mapper = readMapper(mapperName);
        assertTrue(mapper.contains("useGeneratedKeys=\"true\""), mapperName);
        assertTrue(mapper.contains("keyProperty=\"id\""), mapperName);
        assertFalse(mapper.contains("LAST_INSERT_ID()"), mapperName);
    }

    private String readMapper(String mapperName) throws IOException {
        return readResource(MAPPER_ROOT + mapperName);
    }

    private String readResource(String resourceName) throws IOException {
        try (InputStream input = getClass().getClassLoader().getResourceAsStream(resourceName)) {
            if (input == null) {
                throw new IOException("Resource not found: " + resourceName);
            }
            return StreamUtils.copyToString(input, StandardCharsets.UTF_8);
        }
    }
}
