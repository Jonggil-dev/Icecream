package com.example.icecream.common.logging;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.util.ContentCachingRequestWrapper;
import org.springframework.web.util.ContentCachingResponseWrapper;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Enumeration;

@Slf4j
@Component
public class LoggingFilter extends OncePerRequestFilter {

    private final ObjectMapper objectMapper;

    public LoggingFilter() {
        this.objectMapper = new ObjectMapper().enable(SerializationFeature.INDENT_OUTPUT);
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        ContentCachingRequestWrapper wrappedRequest = new ContentCachingRequestWrapper(request);
        ContentCachingResponseWrapper wrappedResponse = new ContentCachingResponseWrapper(response);

        filterChain.doFilter(wrappedRequest, wrappedResponse);

        logRequest(wrappedRequest);
        logResponse(wrappedResponse);

        wrappedResponse.copyBodyToResponse();
    }

    private void logRequest(ContentCachingRequestWrapper request) {
        String requestBody = getRequestBody(request);
        String prettyRequestBody = prettyPrintJson(requestBody);

        log.info("Incoming request data: {{\n  \"method\": \"{}\",\n  \"uri\": \"{}\",\n  \"correlationId\": \"{}\",\n  \"headers\": {},\n  \"body\": {}\n}}",
                request.getMethod(), request.getRequestURI(), MDC.get("correlationId"), getHeaders(request), indentJson(prettyRequestBody));
    }

    private void logResponse(ContentCachingResponseWrapper response) throws IOException {
        String responseBody = getResponseBody(response);
        String prettyResponseBody = prettyPrintJson(responseBody);

        log.info("Outgoing response data: {{\n  \"status\": {},\n  \"correlationId\": \"{}\",\n  \"body\": {}\n}}",
                response.getStatus(), MDC.get("correlationId"), indentJson(prettyResponseBody));
    }

    private String getHeaders(HttpServletRequest request) {
        StringBuilder headers = new StringBuilder("{\n");
        Enumeration<String> headerNames = request.getHeaderNames();
        while (headerNames.hasMoreElements()) {
            String headerName = headerNames.nextElement();
            headers.append("    \"").append(headerName).append("\": \"").append(request.getHeader(headerName)).append("\",\n");
        }
        if (headers.length() > 2) {
            headers.setLength(headers.length() - 2);
        }
        headers.append("\n  }");
        return headers.toString();
    }

    private String getRequestBody(ContentCachingRequestWrapper request) {
        byte[] content = request.getContentAsByteArray();
        return new String(content, StandardCharsets.UTF_8);
    }

    private String getResponseBody(ContentCachingResponseWrapper response) throws IOException {
        byte[] content = response.getContentAsByteArray();
        return new String(content, StandardCharsets.UTF_8);
    }

    private String prettyPrintJson(String json) {
        try {
            Object jsonObject = objectMapper.readValue(json, Object.class);
            return objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(jsonObject);
        } catch (IOException e) {
            return json;
        }
    }

    private String indentJson(String json) {
        StringBuilder indentedJson = new StringBuilder();
        String[] lines = json.split("\n");
        for (String line : lines) {
            indentedJson.append("  ").append(line).append("\n");
        }
        if (!indentedJson.isEmpty()) {
            indentedJson.setLength(indentedJson.length() - 1);
        }
        return indentedJson.toString();
    }
}