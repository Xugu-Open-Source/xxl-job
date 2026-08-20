package com.xxl.job.admin.it.xugu;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;

import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Gated IT: apply the XuGu DDL script (doc/db/tables_xxl_job_xugu.sql) against the
 * real engine and assert the seeded schema is queryable. The control-plane gate
 * activates this class with {@code -Pxugu-it} plus env {@code XUGU_IT=1} and
 * {@code XUGU_JDBC_URL}; plain {@code mvn test} keeps upstream test selection.
 */
@EnabledIfEnvironmentVariable(named = "XUGU_IT", matches = "1")
class XuGuSchemaIT {

    private static final String SCRIPT = Paths.get("..", "doc", "db", "tables_xxl_job_xugu.sql").toString();

    @Test
    void applyXuguSchemaScriptAndVerifySeed() throws Exception {
        Path script = Paths.get(SCRIPT);
        assertTrue(Files.isRegularFile(script), "XuGu DDL script missing: " + SCRIPT);

        Class.forName("com.xugu.cloudjdbc.Driver");
        try (Connection connection = openXuguConnection()) {
            // Control-plane integration gate: stderr marker proves a real engine connection.
            System.err.println("XUGU_ENGINE_CONNECTED product=" + connection.getMetaData().getDatabaseProductVersion());

            List<String> statements = splitStatements(Files.readAllLines(script, StandardCharsets.UTF_8));
            dropXxlTables(connection, statements);
            for (String sql : statements) {
                try (Statement statement = connection.createStatement()) {
                    statement.execute(sql);
                }
            }
            assertTrue(countRows(connection, "xxl_job_group") >= 1, "seed data missing in xxl_job_group");
            assertTrue(countRows(connection, "xxl_job_info") >= 1, "seed data missing in xxl_job_info");
            System.err.println("XUGU_SCHEMA_APPLIED tables=" + xxlTables(statements).size());
        }
    }

    private static Connection openXuguConnection() throws SQLException {
        String url = envOrDefault("XUGU_JDBC_URL", "jdbc:xugu://127.0.0.1:5138/XXLJOB_TEST");
        String user = envOrDefault("XUGU_JDBC_USER", envOrDefault("XUGU_USER", "SYSDBA"));
        String password = envOrDefault("XUGU_JDBC_PASSWORD", envOrDefault("XUGU_PASSWORD", "SYSDBA"));
        return DriverManager.getConnection(url, user, password);
    }

    private static String envOrDefault(String name, String fallback) {
        String value = System.getenv(name);
        return (value == null || value.trim().isEmpty()) ? fallback : value.trim();
    }

    /**
     * Strip comments plus {@code use}/{@code create database} lines and accumulate
     * complete {@code ';'}-terminated statements exactly as the engine accepts them.
     */
    private static List<String> splitStatements(List<String> lines) {
        List<String> statements = new ArrayList<>();
        StringBuilder current = new StringBuilder();
        for (String line : lines) {
            String trimmed = line.trim();
            if (trimmed.isEmpty() || trimmed.startsWith("#") || trimmed.startsWith("--")) {
                continue;
            }
            String lower = trimmed.toLowerCase();
            if (lower.startsWith("use ") || lower.startsWith("create database")) {
                continue;
            }
            current.append(trimmed).append("\n");
            if (trimmed.endsWith(";")) {
                statements.add(current.toString());
                current.setLength(0);
            }
        }
        if (current.length() > 0) {
            statements.add(current.toString());
        }
        return statements;
    }

    private static List<String> xxlTables(List<String> statements) {
        List<String> tables = new ArrayList<>();
        for (String sql : statements) {
            String trimmed = sql.trim();
            if (!trimmed.toLowerCase().startsWith("create table")) {
                continue;
            }
            int start = trimmed.indexOf('`');
            int end = start < 0 ? -1 : trimmed.indexOf('`', start + 1);
            if (start >= 0 && end > start) {
                tables.add(trimmed.substring(start + 1, end));
            }
        }
        return tables;
    }

    /** The DDL script has no IF NOT EXISTS, so re-runs must drop the tables first. */
    private static void dropXxlTables(Connection connection, List<String> statements) throws SQLException {
        try (Statement statement = connection.createStatement()) {
            for (String table : xxlTables(statements)) {
                statement.execute("DROP TABLE IF EXISTS " + table);
            }
        }
    }

    private static int countRows(Connection connection, String table) throws SQLException {
        try (Statement statement = connection.createStatement();
                ResultSet resultSet = statement.executeQuery("SELECT COUNT(*) FROM " + table)) {
            resultSet.next();
            return resultSet.getInt(1);
        }
    }
}
