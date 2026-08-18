package sit.chat2date.cp25ssi2;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class Cp25ssi2Application {

	public static void main(String[] args) {
		SpringApplication.run(Cp25ssi2Application.class, args);
	}

}
