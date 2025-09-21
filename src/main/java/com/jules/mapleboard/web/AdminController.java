package com.jules.mapleboard.web;

import com.jules.mapleboard.mapper.PostMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;


@Tag(name = "Admin", description = "管理员接口示例")
@RestController
@RequestMapping("/api/admin")
@CrossOrigin
public class AdminController {
    private final PostMapper postMapper;


    public AdminController(PostMapper postMapper) { this.postMapper = postMapper; }


    @Operation(summary = "删除帖子（管理员）")
    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/posts/{id}")
    public String deletePost(@PathVariable Long id) {
        postMapper.deleteById(id);
        return "ok";
    }
}