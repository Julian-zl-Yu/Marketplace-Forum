package com.jules.mapleboard.dto;

import jakarta.validation.constraints.*;
import lombok.Data;


@Data
public class CommentCreateRequest {


    @NotBlank
    private String content;
}