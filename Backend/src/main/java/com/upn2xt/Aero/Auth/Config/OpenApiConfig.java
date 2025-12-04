package com.upn2xt.Aero.Auth.Config;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeIn;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.info.Contact;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.info.License;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import org.springframework.context.annotation.Configuration;

@Configuration
@OpenAPIDefinition(
        info = @Info(
                contact = @Contact(
                        name = "Aero HR System",
                        email = "support@upn2xt.com",
                        url = "https://upn2xt.com"
                ),
                description = "Documentation for Aero HR System APIs.<br /><br />" +
                        "<strong><h3>Authentication Guide</h3></strong>" +
                        "This API uses JWT (JSON Web Tokens) for authentication. " +
                        "After logging in via <code>/api/auth/login/employee</code> or <code>/api/auth/login/hr</code>, " +
                        "you will receive a token.<br /><br />" +
                        "<strong>How to use in Swagger:</strong> Click the green <strong>Authorize</strong> button above, " +
                        "and paste just the token (the system adds 'Bearer ' automatically if configured, but usually you paste the raw token).<br /><br />" +
                        "<strong>How to use in JavaScript (Fetch):</strong><br />" +
                        "<pre>" +
                        "fetch('http://localhost:8080/api/endpoint', {\n" +
                        "  method: 'GET',\n" +
                        "  headers: {\n" +
                        "    'Authorization': 'Bearer ' + your_jwt_token,\n" +
                        "    'Content-Type': 'application/json'\n" +
                        "  }\n" +
                        "});" +
                        "</pre>",
                title = "Aero HR API",
                version = "1.0",
                license = @License(
                        name = "Proprietary",
                        url = "https://upn2xt.com/license"
                ),
                termsOfService = "Terms of service"
        ),
        security = {
                @SecurityRequirement(name = "bearerAuth")
        }
)
@SecurityScheme(
        name = "bearerAuth",
        description = "JWT auth description",
        scheme = "bearer",
        type = SecuritySchemeType.HTTP,
        bearerFormat = "JWT",
        in = SecuritySchemeIn.HEADER
)
public class OpenApiConfig {
}
