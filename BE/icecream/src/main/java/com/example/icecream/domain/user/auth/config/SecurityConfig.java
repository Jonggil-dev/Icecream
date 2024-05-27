package com.example.icecream.domain.user.auth.config;

import com.example.icecream.common.logging.CorrelationIdFilter;
import com.example.icecream.common.logging.LoggingFilter;
import com.example.icecream.domain.user.auth.filter.JwtAuthenticationFilter;
import com.example.icecream.domain.user.auth.filter.LoginIdAuthenticationFilter;
import com.example.icecream.domain.user.auth.handler.CustomAccessDeniedHandler;
import com.example.icecream.domain.user.auth.handler.CustomAuthenticationEntryPoint;
import com.example.icecream.domain.user.auth.handler.CustomAuthenticationSuccessHandler;
import com.example.icecream.domain.user.auth.service.CustomUserDetailsService;

import com.example.icecream.domain.user.auth.util.JwtUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;

import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.crypto.factory.PasswordEncoderFactories;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final ObjectMapper objectMapper;
    private final JwtUtil jwtUtil;
    private final CustomUserDetailsService customUserDetailService;
    private final CustomAuthenticationSuccessHandler customAuthenticationSuccessHandler;
    private final CustomAuthenticationEntryPoint customAuthenticationEntryPoint;
    private final CustomAccessDeniedHandler customAccessDeniedHandler;
    private final LoggingFilter loggingFilter;
    private final CorrelationIdFilter correlationIdFilter;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity httpSecurity, AuthenticationManager authenticationManager) throws Exception {
        LoginIdAuthenticationFilter loginIdAuthenticationFilter = new LoginIdAuthenticationFilter(authenticationManager, customAuthenticationSuccessHandler, objectMapper);
        JwtAuthenticationFilter jwtAuthenticationFilter = new JwtAuthenticationFilter(jwtUtil, objectMapper);

        return httpSecurity
                .formLogin(AbstractHttpConfigurer::disable)
                .httpBasic(AbstractHttpConfigurer::disable)
                .csrf(AbstractHttpConfigurer::disable)
                .sessionManagement(management ->
                        management.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(authorize -> authorize
                        .requestMatchers(HttpMethod.POST, "/users").permitAll()
                        .requestMatchers("/users/check", "/auth/login", "/auth/device/login","/auth/reissue", "/error").permitAll()
                        .requestMatchers(HttpMethod.GET, "/destination", "/goal", "/goal/status").hasAnyRole("CHILD", "PARENT")
                        .anyRequest().hasRole("PARENT"))
                .exceptionHandling((exceptionConfig) ->
                        exceptionConfig
                                .authenticationEntryPoint(customAuthenticationEntryPoint)
                                .accessDeniedHandler(customAccessDeniedHandler))
                .addFilterBefore(correlationIdFilter, UsernamePasswordAuthenticationFilter.class)
                .addFilterBefore(loggingFilter, UsernamePasswordAuthenticationFilter.class)
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
                .addFilterAt(loginIdAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
                .build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return PasswordEncoderFactories.createDelegatingPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(HttpSecurity http) throws Exception {
        AuthenticationManagerBuilder authManagerBuilder =  http.getSharedObject(AuthenticationManagerBuilder.class);
        authManagerBuilder.userDetailsService(customUserDetailService)
                .passwordEncoder(passwordEncoder());
        return authManagerBuilder.build();
    }
}