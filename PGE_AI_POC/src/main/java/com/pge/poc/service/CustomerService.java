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
        CustomerUsage usage = repository.findById(accountId)
            .orElseThrow(() -> new RuntimeException(""Customer not found""));

        String prompt = String.format(
            ""You are a PG&E billing assistant.\nCustomer %s (Account %s) has the following usage for %s:\n- Total electricity usage: %d kWh\n- Peak usage charges: $%.2f\n- Previous month bill: $%.2f\nCustomer asked: '%s'\nExplain in a friendly, clear way why the bill is what it is."",
            usage.getName(), usage.getAccountId(), usage.getMonth(),
            usage.getUsageKwh(), usage.getPeakCharges(), usage.getPreviousBill(),
            question
        );

        return llmClient.getLLMResponse(prompt);
    }
}
