package com.pge.poc.repository;
import com.pge.poc.model.CustomerUsage;
import org.springframework.data.jpa.repository.JpaRepository;
public interface CustomerRepository extends JpaRepository<CustomerUsage, String> {}