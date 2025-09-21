package com.jules.mapleboard.web;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.jules.mapleboard.domain.Comment;
import com.jules.mapleboard.domain.Post;
import com.jules.mapleboard.domain.User;
import com.jules.mapleboard.dto.CommentCreateRequest;
import com.jules.mapleboard.mapper.CommentMapper;
import com.jules.mapleboard.mapper.PostMapper;
import com.jules.mapleboard.mapper.UserMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Comments", description = "评论相关接口")
@RestController
@RequestMapping("/api/comments")
@CrossOrigin
public class CommentController {

    private final PostMapper postMapper;
    private final CommentMapper commentMapper;
    private final UserMapper userMapper;

    public CommentController(PostMapper postMapper, CommentMapper commentMapper, UserMapper userMapper) {
        this.postMapper = postMapper;
        this.commentMapper = commentMapper;
        this.userMapper = userMapper;
    }

    @Operation(summary = "评论列表")
    @GetMapping("/{postId}/comments")
    public List<Comment> listByPath(@PathVariable Long postId,
                                    @RequestParam(defaultValue = "0") Integer page,
                                    @RequestParam(defaultValue = "20") Integer size) {
        // 确保帖子存在
        if (postMapper.selectById(postId) == null) {
            throw new IllegalArgumentException("Post not found");
        }
        // 这里先返回全量列表（按创建时间升序），如需真正分页可改为 selectPage
        return commentMapper.selectList(new LambdaQueryWrapper<Comment>()
                .eq(Comment::getPostId, postId)
                .orderByAsc(Comment::getCreatedAt));
    }

    @Operation(summary = "评论列表（query 兼容）")
    @GetMapping(params = "postId")
    public List<Comment> listByQuery(@RequestParam Long postId,
                                     @RequestParam(defaultValue = "0") Integer page,
                                     @RequestParam(defaultValue = "20") Integer size) {
        if (postMapper.selectById(postId) == null) {
            throw new IllegalArgumentException("Post not found");
        }
        return commentMapper.selectList(new LambdaQueryWrapper<Comment>()
                .eq(Comment::getPostId, postId)
                .orderByAsc(Comment::getCreatedAt));
    }

    @Operation(summary = "发表评论（后端自动写作者）")
    @PostMapping("/{postId}/comments")
    public ResponseEntity<?> createComment(@PathVariable Long postId,
                                           @Valid @RequestBody CommentCreateRequest dto,
                                           Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        String currentUsername = authentication.getName();

        Post post = postMapper.selectById(postId);
        if (post == null) return ResponseEntity.notFound().build();

        User u = userMapper.selectOne(
                new LambdaQueryWrapper<User>().eq(User::getUsername, currentUsername)
        );

        Comment c = new Comment();
        c.setPostId(postId);
        c.setContent(dto.getContent());
        // ★ 自动填充作者
        c.setAuthor(currentUsername);
        if (u != null) c.setUserId(u.getId());

        commentMapper.insert(c);
        return ResponseEntity.status(HttpStatus.CREATED).body(c);
    }

    @Operation(summary = "删除自己的评论（非管理员，只有作者本人可删）")
    @DeleteMapping("/{postId}/comments/{id}")
    public ResponseEntity<?> deleteOwnComment(@PathVariable Long postId,
                                              @PathVariable Long id,
                                              Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        Comment c = commentMapper.selectById(id);
        if (c == null || !postId.equals(c.getPostId())) {
            return ResponseEntity.notFound().build();
        }

        String currentUser = authentication.getName();
        User u = userMapper.selectOne(new LambdaQueryWrapper<User>().eq(User::getUsername, currentUser));

        boolean isOwner = (c.getUserId() != null && u != null && c.getUserId().equals(u.getId()))
                || currentUser.equals(c.getAuthor());

        if (!isOwner) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("You can only delete your own comment.");
        }

        commentMapper.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
