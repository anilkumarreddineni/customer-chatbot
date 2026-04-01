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
        WebClient client = WebClient.builder()
                .baseUrl(OPENAI_URL)
                .defaultHeader(HttpHeaders.AUTHORIZATION, ""Bearer "" + OPENAI_API_KEY)
                .build();

        Map<String, Object> requestBody = Map.of(
                ""model"", ""gpt-4-turbo"",
                ""messages"", List.of(Map.of(""role"", ""user"", ""content"", prompt))
        );

        Map<String, Object> response = client.post()
                .bodyValue(requestBody)
                .retrieve()
                .bodyToMono(Map.class)
                .block();

        List<Map<String, Object>> choices = (List<Map<String, Object>>) response.get(""choices"");
        Map<String, Object> message = (Map<String, Object>) choices.get(0).get(""message"");
        return (String) message.get(""content"");
    }
}
