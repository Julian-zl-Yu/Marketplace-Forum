package com.jules.mapleboard.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;


@Data
@TableName(value = "posts")
public class Post {
    @TableId(type = IdType.AUTO)
    private Long id;


    private String category;


    private String title;
    private String content;
    private String author;
    private Long userId;


    private String location;
    private BigDecimal price;
    private String company;
    private BigDecimal wage;


    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
