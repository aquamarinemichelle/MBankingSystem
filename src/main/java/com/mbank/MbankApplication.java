package com.mbank;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class MbankApplication {

    public static void main(String[] args) {
        SpringApplication.run(MbankApplication.class, args);
        System.out.println("=========================================");
        System.out.println("   MBank Started Successfully!");
        System.out.println("=========================================");
        System.out.println("Local URL: http://localhost:8080");
        System.out.println("Login URL: http://localhost:8080/login");
        System.out.println("Health Check: http://localhost:8080/ping");
        System.out.println("Database: Supabase PostgreSQL");
        System.out.println("Project URL: https://tznxeiuqbxpicwqrmzfq.supabase.co");
        System.out.println("=========================================");
    }
}