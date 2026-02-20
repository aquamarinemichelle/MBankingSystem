package com.mbank.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.HashMap;
import java.util.Map;

@RestController
public class HealthController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/ping")
    public Map<String, Object> ping() {
        Map<String, Object> response = new HashMap<>();
        try {
            String result = jdbcTemplate.queryForObject(
                    "SELECT 'Connected to Supabase PostgreSQL!'", String.class);

            String version = jdbcTemplate.queryForObject(
                    "SELECT version()", String.class);

            response.put("status", "SUCCESS");
            response.put("message", result);
            response.put("database", "Supabase");
            response.put("project_url", "https://tznxeiuqbxpicwqrmzfq.supabase.co");
            response.put("version", version);
            response.put("timestamp", System.currentTimeMillis());

        } catch (Exception e) {
            response.put("status", "ERROR");
            response.put("message", e.getMessage());
            response.put("timestamp", System.currentTimeMillis());
        }
        return response;
    }

    @GetMapping("/db-check")
    public Map<String, Object> checkDatabase() {
        Map<String, Object> response = new HashMap<>();
        try {
            Integer accountCount = jdbcTemplate.queryForObject(
                    "SELECT COUNT(*) FROM accounts", Integer.class);

            Integer transactionCount = jdbcTemplate.queryForObject(
                    "SELECT COUNT(*) FROM transactions", Integer.class);

            response.put("status", "CONNECTED");
            response.put("accounts_count", accountCount);
            response.put("transactions_count", transactionCount);
            response.put("database", "Supabase");
            response.put("project", "tznxeiuqbxpicwqrmzfq");

        } catch (Exception e) {
            response.put("status", "ERROR");
            response.put("message", e.getMessage());
        }
        return response;
    }

    @GetMapping("/supabase-info")
    public Map<String, String> getSupabaseInfo() {
        Map<String, String> info = new HashMap<>();
        info.put("project_url", "https://tznxeiuqbxpicwqrmzfq.supabase.co");
        info.put("database", "PostgreSQL on Supabase");
        info.put("status", "Configured");
        info.put("note", "API keys are kept secure in environment variables");
        return info;
    }
}