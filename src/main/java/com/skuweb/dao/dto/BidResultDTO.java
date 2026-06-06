package com.skuweb.dao.dto;

public class BidResultDTO {
    private boolean success;
    private String message;
    private int currentPrice;

    public BidResultDTO(boolean success, String message) {
        this.success = success;
        this.message = message;
    }

    public BidResultDTO(boolean success, String message, int currentPrice) {
        this.success = success;
        this.message = message;
        this.currentPrice = currentPrice;
    }

    public boolean isSuccess() {
        return success;
    }

    public String getMessage() {
        return message;
    }

    public int getCurrentPrice() {
        return currentPrice;
    }
}