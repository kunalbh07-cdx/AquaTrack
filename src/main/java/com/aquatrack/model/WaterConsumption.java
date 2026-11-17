
package com.aquatrack.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class WaterConsumption {

    private int consumptionId;
    private int userId;
    private String category;
    private BigDecimal amountLiters;
    private String notes;
    private Timestamp recordedAt;

    // Default constructor
    public WaterConsumption() {
    }

    // Constructor for adding consumption
    public WaterConsumption(
            int userId,
            String category,
            BigDecimal amountLiters,
            String notes) {

        this.userId = userId;
        this.category = category;
        this.amountLiters = amountLiters;
        this.notes = notes;
    }

    // Getters and Setters

    public int getConsumptionId() {
        return consumptionId;
    }

    public void setConsumptionId(int consumptionId) {
        this.consumptionId = consumptionId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public BigDecimal getAmountLiters() {
        return amountLiters;
    }

    public void setAmountLiters(BigDecimal amountLiters) {
        this.amountLiters = amountLiters;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Timestamp getRecordedAt() {
        return recordedAt;
    }

    public void setRecordedAt(Timestamp recordedAt) {
        this.recordedAt = recordedAt;
    }
}
