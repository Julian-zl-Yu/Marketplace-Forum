package com.jules.mapleboard.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;


@Data
@TableName(value = "comments")
public class Comment {
    @TableId(type = IdType.AUTO)
    private Long id;


    @TableField("post_id")
    private Long postId;


    private String author;
    private String content;
    private Long userId;


    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}