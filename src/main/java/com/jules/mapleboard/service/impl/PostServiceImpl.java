package com.jules.mapleboard.service.impl;

import com.jules.mapleboard.domain.Post;
import com.jules.mapleboard.mapper.PostMapper;
import com.jules.mapleboard.service.PostService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;


@Service
public class PostServiceImpl implements PostService {
    private final PostMapper postMapper;


    public PostServiceImpl(PostMapper postMapper) {
        this.postMapper = postMapper;
    }


    @Override
    public Page<Post> list(String category, int page, int size, String keyword) {
        if (size > 50) size = 50;
        Page<Post> p = new Page<>(page + 1L, size); // MP 的页码从 1 开始
        LambdaQueryWrapper<Post> qw = new LambdaQueryWrapper<Post>()
                .orderByDesc(Post::getCreatedAt);
        if (StringUtils.hasText(category)) {
            qw.eq(Post::getCategory, category);
        }
        if (StringUtils.hasText(keyword)) {
            qw.like(Post::getTitle, keyword);
        }
        return postMapper.selectPage(p, qw);
    }


    @Override
    public Post create(Post post) {
        postMapper.insert(post);
        return post;
    }


    @Override
    public Post get(Long id) {
        Post p = postMapper.selectById(id);
        if (p == null) throw new IllegalArgumentException("Post not found");
        return p;
    }
}