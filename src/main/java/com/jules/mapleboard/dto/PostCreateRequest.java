package com.jules.mapleboard.dto;

import com.jules.mapleboard.domain.Category;
import jakarta.validation.constraints.*;
import lombok.Data;
import java.math.BigDecimal;


@Data
public class PostCreateRequest {
    @NotNull
    private Category category;


    @NotBlank
    @Size(max = 120)
    private String title;


    @NotBlank
    private String content;




    private String location;
    private BigDecimal price;
    private String company;
    private BigDecimal wage;
}
