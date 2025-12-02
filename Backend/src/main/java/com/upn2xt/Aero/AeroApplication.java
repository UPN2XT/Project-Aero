package com.upn2xt.Aero;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.jdbc.core.JdbcTemplate;

@SpringBootApplication
public class AeroApplication {

	public static void main(String[] args) {
		SpringApplication.run(AeroApplication.class, args);
	}
    @Bean
    public CommandLineRunner executeTableCreation(JdbcTemplate jdbcTemplate) {
        return args -> {
            try {
                // This executes the stored procedure using standard T-SQL syntax
                jdbcTemplate.execute("EXEC dbo.createAllTables");
                System.out.println("✅ dbo.createAllTables executed successfully.");
            } catch (Exception e) {
                System.err.println("❌ Error executing dbo.createAllTables: " + e.getMessage());
            }
        };
    }

}
