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
                jdbcTemplate.execute("EXEC dbo.dropAllTables");
                System.out.println("✅ dbo.deletesAllTables executed successfully.");
            } catch (Exception e) {
                System.err.println("❌ Error executing dbo.createAllTables: " + e.getMessage());
            }
            //Create_Holiday

            try {
                // This executes the stored procedure using standard T-SQL syntax
                jdbcTemplate.execute("EXEC dbo.createAllTables");
                System.out.println("✅ dbo.createAllTables executed successfully.");
            } catch (Exception e) {
                System.err.println("❌ Error executing dbo.createAllTables: " + e.getMessage());
            }

            try {
                jdbcTemplate.execute("EXEC dbo.init_values");
                System.out.println("✅ dbo.init_values executed successfully.");
            } catch (Exception e) {
                System.err.println("❌ Error executing dbo.init_values: " + e.getMessage());
            }

            try {
                // This executes the stored procedure using standard T-SQL syntax
                jdbcTemplate.execute("EXEC dbo.Create_Holiday");
                System.out.println("✅ dbo.Create_Holiday executed successfully.");
            } catch (Exception e) {
                System.err.println("❌ Error executing dbo.Create_Holiday: " + e.getMessage());
            }
        };
    }

}
