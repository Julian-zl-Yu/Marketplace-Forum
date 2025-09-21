package com.jules.mapleboard.service;

import com.jules.mapleboard.domain.Post;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;


public interface PostService {
    Page<Post> list(String category, int page, int size, String keyword);
    Post create(Post post);
    Post get(Long id);
}