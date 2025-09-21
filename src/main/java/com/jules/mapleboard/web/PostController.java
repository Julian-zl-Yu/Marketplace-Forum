package com.jules.mapleboard.web;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.jules.mapleboard.domain.Category;
import com.jules.mapleboard.domain.Comment;
import com.jules.mapleboard.domain.Post;
import com.jules.mapleboard.domain.User;
import com.jules.mapleboard.dto.PostCreateRequest;
import com.jules.mapleboard.dto.PostResponse;
import com.jules.mapleboard.mapper.CommentMapper;
import com.jules.mapleboard.mapper.PostMapper;
import com.jules.mapleboard.mapper.UserMapper;
import com.jules.mapleboard.service.PostService;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;


@Tag(name = "Posts", description = "帖子相关接口")
@RestController
@RequestMapping("/api/posts")
@CrossOrigin
public class PostController {
    private final PostService postService;
    private final PostMapper postMapper;
    private final CommentMapper commentMapper;
    private final UserMapper userMapper;

    public PostController(PostService postService, PostMapper postMapper, CommentMapper commentMapper, UserMapper userMapper) {
        this.postService = postService;
        this.postMapper = postMapper;
        this.commentMapper = commentMapper;
        this.userMapper = userMapper;
    }


    @Operation(summary = "分页列表", description = "可按分类与关键字查询（title LIKE）")
    @GetMapping
    public Page<Post> list(@RequestParam(required = false) Category category,
                           @RequestParam(defaultValue = "0") int page,
                           @RequestParam(defaultValue = "10") int size,
                           @RequestParam(required = false) String keyword) {
        String cat = category == null ? null : category.name();
        return postService.list(cat, page, size, keyword);
    }


    @Operation(summary = "创建帖子（后端自动写作者）")
    @PostMapping
    public ResponseEntity<?> createPost(@Valid @RequestBody PostCreateRequest dto,
                                        Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        String currentUsername = authentication.getName();

        User u = userMapper.selectOne(
                new LambdaQueryWrapper<User>().eq(User::getUsername, currentUsername)
        );

        Post p = new Post();
        p.setCategory(String.valueOf(dto.getCategory()));
        p.setTitle(dto.getTitle());
        p.setContent(dto.getContent());

        // 自动填充作者
        p.setAuthor(currentUsername);
        if (u != null) p.setUserId(u.getId());

        // 可选字段
        p.setLocation(dto.getLocation());
        p.setPrice(dto.getPrice());
        p.setCompany(dto.getCompany());
        p.setWage(dto.getWage());

        postMapper.insert(p);
        return ResponseEntity.status(HttpStatus.CREATED).body(p);
    }


    @Operation(summary = "帖子详情")
    @GetMapping("/{id}")
    public PostResponse get(@PathVariable Long id) {
        Post p = postService.get(id);
        PostResponse r = new PostResponse();
        r.setId(p.getId());
        r.setCategory(Category.valueOf(p.getCategory()));
        r.setTitle(p.getTitle());
        r.setContent(p.getContent());
        r.setAuthor(p.getAuthor());
        r.setLocation(p.getLocation());
        r.setPrice(p.getPrice());
        r.setCompany(p.getCompany());
        r.setWage(p.getWage());
        r.setCreatedAt(p.getCreatedAt());
        return r;
    }

    @Operation(summary = "删除自己的帖子（非管理员，只有作者本人可删）")
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteOwnPost(@PathVariable Long id, Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        Post post = postMapper.selectById(id);
        if (post == null) return ResponseEntity.notFound().build();

        String currentUser = authentication.getName();
        User u = userMapper.selectOne(new LambdaQueryWrapper<User>().eq(User::getUsername, currentUser));

        boolean isOwner = (post.getUserId()!=null && u!=null && post.getUserId().equals(u.getId()))
                || currentUser.equals(post.getAuthor());

        if (!isOwner) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("You can only delete your own post.");
        }

        //级联删除该帖下的评论
        commentMapper.delete(new LambdaQueryWrapper<Comment>().eq(Comment::getPostId, id));
        postMapper.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}