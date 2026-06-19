package com.im.utils;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.im.dto.Result;
import com.im.enums.ResultCode;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
@RequiredArgsConstructor
public class JwtInterceptor implements HandlerInterceptor {

    private final JwtUtil jwtUtil;
    private final ObjectMapper objectMapper;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // OPTIONS请求放行
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }

        String token = request.getHeader("Authorization");
        if (!StringUtils.hasText(token) || !token.startsWith("Bearer ")) {
            sendError(response, ResultCode.TOKEN_INVALID);
            return false;
        }

        token = token.substring(7);

        if (!jwtUtil.validateToken(token)) {
            sendError(response, ResultCode.TOKEN_EXPIRED);
            return false;
        }

        Long userId = jwtUtil.getUserIdFromToken(token);
        request.setAttribute("userId", userId);
        return true;
    }

    private void sendError(HttpServletResponse response, ResultCode resultCode) throws Exception {
        response.setContentType("application/json;charset=UTF-8");
        response.setStatus(200);
        response.getWriter().write(objectMapper.writeValueAsString(Result.failed(resultCode)));
    }
}
