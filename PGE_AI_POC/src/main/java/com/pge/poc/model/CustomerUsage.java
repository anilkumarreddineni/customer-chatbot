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
        this.accountId = accountId;
        this.name = name;
        this.month = month;
        this.usageKwh = usageKwh;
        this.peakCharges = peakCharges;
        this.previousBill = previousBill;
    }

    // Getters & Setters...
    public String getAccountId() { return accountId; }
    public void setAccountId(String accountId) { this.accountId = accountId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getMonth() { return month; }
    public void setMonth(String month) { this.month = month; }
    public int getUsageKwh() { return usageKwh; }
    public void setUsageKwh(int usageKwh) { this.usageKwh = usageKwh; }
    public double getPeakCharges() { return peakCharges; }
    public void setPeakCharges(double peakCharges) { this.peakCharges = peakCharges; }
    public double getPreviousBill() { return previousBill; }
    public void setPreviousBill(double previousBill) { this.previousBill = previousBill; }
}
