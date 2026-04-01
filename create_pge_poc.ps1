$projectRoot = "C:\Users\anilk\OneDrive\akr\learning\customer-chatbot-pge\PGE_AI_POC"
$zipPath = "C:\Users\anilk\OneDrive\akr\learning\customer-chatbot-pge\PGE_AI_POC.zip"

# Delete if already exists
if (Test-Path $projectRoot) { Remove-Item $projectRoot -Recurse -Force }
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

# Create folders
$folders = @(
    "$projectRoot\src\main\java\com\pge\poc\controller",
    "$projectRoot\src\main\java\com\pge\poc\model",
    "$projectRoot\src\main\java\com\pge\poc\repository",
    "$projectRoot\src\main\java\com\pge\poc\service",
    "$projectRoot\src\main\resources"
)
foreach ($f in $folders) { New-Item -ItemType Directory -Force -Path $f }

# BOM-free helper function
function OutFileNoBOM([string]$path,[string]$content){
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
}

# 1. pom.xml
OutFileNoBOM "$projectRoot\pom.xml" @"
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.pge</groupId>
    <artifactId>pge-ai-poc</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <packaging>jar</packaging>
    <name>PGE AI POC</name>
    <description>POC for PG&E Customer Automation using LLM</description>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.2</version>
        <relativePath/>
    </parent>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-webflux</artifactId>
        </dependency>
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
        </dependency>
    </dependencies>
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
"@

# 2. application.properties
OutFileNoBOM "$projectRoot\src\main\resources\application.properties" @"
spring.datasource.url=jdbc:h2:mem:pgedb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.h2.console.enabled=true
spring.jpa.hibernate.ddl-auto=create

openai.api.key=YOUR_API_KEY
"@

# 3. data.sql
OutFileNoBOM "$projectRoot\src\main\resources\data.sql" @"
INSERT INTO CUSTOMER_USAGE VALUES ('123456', 'John Doe', 'March 2026', 450, 30.0, 380.0);
INSERT INTO CUSTOMER_USAGE VALUES ('234567', 'Jane Smith', 'March 2026', 520, 25.0, 400.0);
"@

# 4. Java files
$files = @{
"PgeAiPocApplication.java" = @"
package com.pge.poc;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
@SpringBootApplication
public class PgeAiPocApplication {
    public static void main(String[] args) {
        SpringApplication.run(PgeAiPocApplication.class, args);
    }
}
"@

"controller\CustomerController.java" = @"
package com.pge.poc.controller;
import com.pge.poc.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
@RestController
@RequestMapping(""/api/customer"")
public class CustomerController {
    @Autowired
    private CustomerService customerService;
    @PostMapping(""/ask"")
    public String askQuestion(@RequestParam String accountId, @RequestParam String question) {
        return customerService.generateAnswer(accountId, question);
    }
}
"@

"model\CustomerUsage.java" = @"
package com.pge.poc.model;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
@Entity
public class CustomerUsage {
    @Id
    private String accountId;
    private String name;
    private String month;
    private int usageKwh;
    private double peakCharges;
    private double previousBill;

    public CustomerUsage() {}
    public CustomerUsage(String accountId, String name, String month, int usageKwh, double peakCharges, double previousBill) {
        this.accountId = accountId; this.name = name; this.month = month; this.usageKwh = usageKwh; this.peakCharges = peakCharges; this.previousBill = previousBill;
    }
    public String getAccountId() { return accountId; } public void setAccountId(String accountId) { this.accountId = accountId; }
    public String getName() { return name; } public void setName(String name) { this.name = name; }
    public String getMonth() { return month; } public void setMonth(String month) { this.month = month; }
    public int getUsageKwh() { return usageKwh; } public void setUsageKwh(int usageKwh) { this.usageKwh = usageKwh; }
    public double getPeakCharges() { return peakCharges; } public void setPeakCharges(double peakCharges) { this.peakCharges = peakCharges; }
    public double getPreviousBill() { return previousBill; } public void setPreviousBill(double previousBill) { this.previousBill = previousBill; }
}
"@

"repository\CustomerRepository.java" = @"
package com.pge.poc.repository;
import com.pge.poc.model.CustomerUsage;
import org.springframework.data.jpa.repository.JpaRepository;
public interface CustomerRepository extends JpaRepository<CustomerUsage, String> {}
"@

"service\CustomerService.java" = @"
package com.pge.poc.service;
import com.pge.poc.model.CustomerUsage;
import com.pge.poc.repository.CustomerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
@Service
public class CustomerService {
    @Autowired
    private CustomerRepository repository;
    @Autowired
    private LLMClient llmClient;
    public String generateAnswer(String accountId, String question) {
        CustomerUsage usage = repository.findById(accountId).orElseThrow(() -> new RuntimeException(""Customer not found""));
        String prompt = String.format(
            ""You are a PG&E billing assistant.\nCustomer %s (Account %s) has the following usage for %s:\n- Total electricity usage: %d kWh\n- Peak usage charges: $%.2f\n- Previous month bill: $%.2f\nCustomer asked: '%s'\nExplain in a friendly, clear way why the bill is what it is."",
            usage.getName(), usage.getAccountId(), usage.getMonth(),
            usage.getUsageKwh(), usage.getPeakCharges(), usage.getPreviousBill(),
            question
        );
        return llmClient.getLLMResponse(prompt);
    }
}
"@

"service\LLMClient.java" = @"
package com.pge.poc.service;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.http.HttpHeaders;
import java.util.List;
import java.util.Map;
@Service
public class LLMClient {
    private static final String OPENAI_API_KEY = System.getProperty(""openai.api.key"", ""YOUR_API_KEY"");
    private static final String OPENAI_URL = ""https://api.openai.com/v1/chat/completions"";
    public String getLLMResponse(String prompt) {
        WebClient client = WebClient.builder().baseUrl(OPENAI_URL).defaultHeader(HttpHeaders.AUTHORIZATION, ""Bearer "" + OPENAI_API_KEY).build();
        Map<String, Object> requestBody = Map.of(""model"", ""gpt-4-turbo"", ""messages"", List.of(Map.of(""role"", ""user"", ""content"", prompt)));
        Map<String, Object> response = client.post().bodyValue(requestBody).retrieve().bodyToMono(Map.class).block();
        List<Map<String, Object>> choices = (List<Map<String, Object>>) response.get(""choices"");
        Map<String, Object> message = (Map<String, Object>) choices.get(0).get(""message"");
        return (String) message.get(""content"");
    }
}
"@
}

# Write files BOM-free
foreach ($file in $files.Keys) {
    $path = Join-Path $projectRoot "src\main\java\com\pge\poc\$file"
    $dir = Split-Path $path
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir }
    OutFileNoBOM $path $files[$file]
}

# Create ZIP
Add-Type -AssemblyName 'System.IO.Compression.FileSystem'
[System.IO.Compression.ZipFile]::CreateFromDirectory($projectRoot, $zipPath)

Write-Host "BOM-free PGE AI POC ZIP created at $zipPath"