package sit.chat2date.cp25ssi2.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * OpenAPI / Swagger configuration for Chat2Date API.
 * Access Swagger UI at: /swagger-ui/index.html
 * Access OpenAPI JSON at: /v3/api-docs
 */
@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI chat2DateOpenAPI() {
        final String securitySchemeName = "Bearer Authentication";

        return new OpenAPI()
                .info(new Info()
                        .title("Chat2Date API")
                        .description("REST API documentation for the Chat2Date dating application")
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("Chat2Date Team")
                                .email("chat2date@sit.kmutt.ac.th")))
                .addSecurityItem(new SecurityRequirement().addList(securitySchemeName))
                .components(new Components()
                        .addSecuritySchemes(securitySchemeName,
                                new SecurityScheme()
                                        .name(securitySchemeName)
                                        .type(SecurityScheme.Type.HTTP)
                                        .scheme("bearer")
                                        .bearerFormat("JWT")
                                        .description("Enter your JWT access token")));
    }
}
