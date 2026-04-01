package com.pge.poc.controller;
import com.pge.poc.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
@RestController
@RequestMapping("/api/customer")
public class CustomerController {
    @Autowired
    private CustomerService customerService;
    @PostMapping("/ask")
    public String askQuestion(@RequestParam String accountId, @RequestParam String question) {
        return customerService.generateAnswer(accountId, question);
    }
}