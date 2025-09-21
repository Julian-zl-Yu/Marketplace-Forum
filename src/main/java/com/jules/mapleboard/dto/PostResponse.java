package com.jules.mapleboard.dto;

import com.jules.mapleboard.domain.Category;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;


@Data
public class PostResponse {
    private Long id;
    private Category category;
    private String title;
    private String content;
    private String author;
    private String location;
    private BigDecimal price;
    private String company;
    private BigDecimal wage;
    private LocalDateTime createdAt;
}